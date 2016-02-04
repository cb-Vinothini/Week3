import java.util.Map;
import java.util.TreeMap;
import java.util.SortedMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Scanner;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.csv.CSVFormat;
import java.io.*;
import java.sql.*;

import javax.sql.DataSource;
import com.mysql.jdbc.jdbc2.optional.MysqlDataSource;

public class PhoneDirectory{
    private static final String [] FILE_HEADER_MAPPING = {"name","address","mobile","home","work"};

    private static final String NAME = "name";
    private static final String ADDRESS = "address";
    private static final String MOBILE_PH = "mobile";
    private static final String HOME_PH = "home";
    private static final String WORK_PH = "work";
    
    public static Scanner scanner = new Scanner(System.in);
    public static Contact[] setData(String fileName) throws IOException{

        FileReader fileReader = null;
        CSVParser csvFileParser = null;
        CSVFormat csvFileFormat = CSVFormat.DEFAULT.withHeader(FILE_HEADER_MAPPING);
        List<Contact> contacts = new ArrayList<Contact>();

        try{
            fileReader = new FileReader(fileName);
            csvFileParser = new CSVParser(fileReader, csvFileFormat);
            List<CSVRecord> csvRecords = csvFileParser.getRecords();
            for (int i = 1; i < csvRecords.size(); i++) {
                CSVRecord record = csvRecords.get(i);
                String mobile = record.get(MOBILE_PH);
                String home = record.get(HOME_PH);
                String work = record.get(WORK_PH);
                Contact contact = new Contact(record.get(NAME), record.get(ADDRESS), mobile, home, work);
                contacts.add(contact);
            }
        }
        catch(Exception e){
            System.out.println(e);
        }
        finally{
                if(fileReader != null)
                    fileReader.close();
                if(csvFileParser != null)
                    csvFileParser.close();
        }
        return contacts.toArray((new Contact[contacts.size()]));
    }
    
    public static void main(String[] args){
        JDBCfile jdbc = new JDBCfile();
        DataSource ds = null;
        String fileName = "phoneData.csv";
        Contact[] contact = null;
        try{
            contact = setData(fileName);
            ds = jdbc.getDataSource();
            jdbc.insertValues(ds, contact);
            char choice;
            do{
                System.out.print("Enter 1. Retrieve by name \n2. Partial retrieve by name\n3. Retrieve by phoneNos\n4. Add Details\n5. Update Details : ");
                int caseChoice = scanner.nextInt();
                String var = null;
                switch(caseChoice){
                    case 1:
                        System.out.print("Enter the name : ");
                        var = scanner.next();
                        jdbc.selectByName(ds, var);
                        break;
                    case 2:
                        System.out.print("Enter the pattern : ");
                        var = scanner.next();
                        jdbc.selectByNamePattern(ds, var);
                        break;
                    case 3:
                        System.out.print("Enter the phone no : ");
                        var = scanner.next();
                        jdbc.selectByPhoneNo(ds, var);
                        break;
                    case 4:
                        Contact newContact = getDetails();
                        jdbc.addRow(ds, newContact);
                        break;
                    case 5:
                        jdbc.displayTable(ds);
                        System.out.print("Enter old contact id : ");
                        Integer id = scanner.nextInt();
                        Contact updateContact = getDetails();
                        jdbc.updateRow(ds, id, updateContact);
                        break;
                    default:
                        System.out.println("Wrong choice");
                }
                System.out.print("Do you want to continue : ");
                choice = scanner.next().charAt(0);
            }while(choice == 'y');
            
        }catch(SQLException sqle){
            sqle.printStackTrace();
        }catch(Exception e){
            System.out.println(e);
        }
    }
    
    public static Contact getDetails(){
        System.out.print("Enter the Contact details name : ");
        String name = scanner.next();
        System.out.print("Address : ");
        String address = scanner.next();
        System.out.print("Mobile : ");
        String mobile = scanner.next();
        System.out.print("Home : ");
        String home = scanner.next();
        System.out.print("Work : ");
        String work = scanner.next();
        Contact newContact = new Contact(name, address, mobile, home, work);
        return newContact;
    }
}

class JDBCfile {
    static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final String DB_URL = "jdbc:mysql://localhost/phone_db";
    
    static final String USER = "root";
    static final String PASS = "";
    
    String selectAll = "SELECT id, name, address, mobile, home, work FROM contacts";
    String selectByName = "SELECT id, name, address, mobile, home, work FROM contacts WHERE name = ?";
    String selectByPattern = "SELECT id, name, address, mobile, home, work FROM contacts WHERE name LIKE CONCAT('%', ?, '%')";
    String selectByNumber = "SELECT id, name, address, mobile, home, work FROM contacts WHERE mobile = ? OR home = ? OR work = ?";
    String insertStat = "INSERT INTO contacts(name, address, mobile, home, work) VALUES (?, ?, ?, ?, ?)";
    String updateRow = "UPDATE contacts SET name = ? ,address = ?, mobile = ?, home = ?, work = ? WHERE id = ?";
    
    public DataSource getDataSource() throws SQLException, Exception{
        MysqlDataSource mysqlDS = null;
        mysqlDS = new MysqlDataSource();
        mysqlDS.setURL(DB_URL);
        mysqlDS.setUser(USER);
        mysqlDS.setPassword(PASS);
        return mysqlDS;
    }

    public void closeConnection(Connection conn) {
        System.out.println("Releasing all open resources ...");
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException sqle) {
            sqle.printStackTrace();
        }
    }
    
    public void closeStatement(Statement stmt) {
        try {
            if (stmt != null) {
                stmt.close();
            }
        } catch (SQLException sqle) {
            sqle.printStackTrace();
        }
    }
    
    public void closePreparedStatement(PreparedStatement preStmt) {
        try {
            if (preStmt != null) {
                preStmt.close();
            }
        } catch (SQLException sqle) {
            sqle.printStackTrace();
        }
    }
    
    public void displayTable(DataSource ds) throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement select = conn.prepareStatement(selectAll);
        ResultSet rs = select.executeQuery();
        displayResultSet(rs);
        closePreparedStatement(select);
        closeConnection(conn);
    }
    
    public void insertValues(DataSource ds, Contact[] contacts) throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement insert = conn.prepareStatement(insertStat);
        for(Contact contact: contacts){
            insert.setString(1, contact.getName());
            insert.setString(2, contact.getAddress());
            insert.setString(3, contact.getMobile());
            insert.setString(4, contact.getHome());
            insert.setString(5, contact.getWork());
            insert.addBatch();
        }
        insert.executeBatch();
        closePreparedStatement(insert);
        closeConnection(conn);
    }
    
    public void selectByName(DataSource ds, String name)throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement selectRow = conn.prepareStatement(selectByName);
        selectRow.setString(1, name);
        ResultSet rs = selectRow.executeQuery();
        displayResultSet(rs);
        closePreparedStatement(selectRow);
        closeConnection(conn);
    }

    public void selectByNamePattern(DataSource ds, String pattern)throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement selectRow = conn.prepareStatement(selectByPattern);
        selectRow.setString(1, pattern);
        System.out.println(selectRow.toString());
        ResultSet rs = selectRow.executeQuery();
        displayResultSet(rs);
        closePreparedStatement(selectRow);
        closeConnection(conn);
    }

    public void selectByPhoneNo(DataSource ds, String number)throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement selectRow = conn.prepareStatement(selectByNumber);
        selectRow.setString(1, number);
        selectRow.setString(2, number);
        selectRow.setString(3, number);
        ResultSet rs = selectRow.executeQuery();
        displayResultSet(rs);
        closePreparedStatement(selectRow);
        closeConnection(conn);
    }
    
    public void addRow(DataSource ds, Contact contact) throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement insert = conn.prepareStatement(insertStat);
        insert.setString(1, contact.getName());
        insert.setString(2, contact.getAddress());
        insert.setString(3, contact.getMobile());
        insert.setString(4, contact.getHome());
        insert.setString(5, contact.getWork());
        insert.executeUpdate();
        closePreparedStatement(insert);
        closeConnection(conn);
    }
    
    public void updateRow(DataSource ds, Integer id, Contact contact) throws SQLException{
        Connection conn = ds.getConnection();
        PreparedStatement update = conn.prepareStatement(updateRow);
        update.setString(1, contact.getName());
        update.setString(2, contact.getAddress());
        update.setString(3, contact.getMobile());
        update.setString(4, contact.getHome());
        update.setString(5, contact.getWork());
        update.setInt(6, id);
        update.executeUpdate();
        closePreparedStatement(update);
        closeConnection(conn);
    }
    
    public void displayResultSet(ResultSet rs) throws SQLException{
        while(rs.next()){
            int id = rs.getInt("id");
            String name = rs.getString("name");
            String address = rs.getString("address");
            String mobile  = rs.getString("mobile");
            String home = rs.getString("home");
            String work = rs.getString("work");
            
            String output = String.format("ID = %d Name : %s, address : %s, mobile : %s, home : %s, work : %s", id,name, address, mobile, home, work);
            System.out.println(output);
        }
    }
}

class Contact{
    private String name, address, mobile, home, work;;
    
    Contact(String name, String address, String mobile, String home, String work){
        this.name = name;
        this.address = address;
        this.mobile = mobile;
        this.home = home;
        this.work = work;
    }
    
    public String getName(){
        return name;
    }
    
    public String getAddress(){
        return address;
    }
    
    public String getMobile(){
        return mobile;
    }

    public String getHome(){
        return home;
    }

    public String getWork(){
        return work;
    }

}