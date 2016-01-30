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

public class PhoneDirectory{
    private static final String [] FILE_HEADER_MAPPING = {"name","address","mobile","home","work"};

    private static final String NAME = "name";
    private static final String ADDRESS = "address";
    private static final String MOBILE_PH = "mobile";
    private static final String HOME_PH = "home";
    private static final String WORK_PH = "work";
    
    private static final String dataBaseName = "phone_db";
    private static final String tableName = "contacts";
    
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

                List<String> phoneNos = new ArrayList<String>();
                phoneNos.add(record.get(MOBILE_PH));
                phoneNos.add(record.get(HOME_PH));
                phoneNos.add(record.get(WORK_PH));
                Contact contact = new Contact(record.get(NAME), record.get(ADDRESS), phoneNos);
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
        Connection conn = null;
        Statement stmt = null;
        String fileName = "phoneData.csv";
        Scanner scanner = new Scanner(System.in);
        Contact[] contact = null;
        try{
            contact = setData(fileName);
            conn = jdbc.getConnectionToDatabase();
            jdbc.createDatabase(conn, dataBaseName);
            jdbc.createTable(conn, tableName);
            jdbc.insertValues(conn, contact, tableName);
            char choice;
            do{
                System.out.print("Enter 1. Retrieve by name \n2. Partial retrieve by name\n3. Retrieve by phoneNos\n4. Add Details\n5. Update Details : ");
                int caseChoice = scanner.nextInt();
                String var = null;
                switch(caseChoice){
                    case 1:
                        System.out.print("Enter the name : ");
                        var = scanner.next();
                        jdbc.selectByName(conn, var, tableName);
                        break;
                    case 2:
                        System.out.print("Enter the pattern : ");
                        var = scanner.next();
                        jdbc.selectByNamePattern(conn, var, tableName);
                        break;
                    case 3:
                        System.out.print("Enter the phone no : ");
                        var = scanner.next();
                        jdbc.selectByPhoneNo(conn, var, tableName);
                        break;
                    case 4:
                        System.out.print("Enter the Contact details name : ");
                        String name = scanner.next();
                        System.out.print("Address : ");
                        String address = scanner.next();
                        List<String> phoneNos = new ArrayList<String>();
                        System.out.print("Mobile : ");
                        phoneNos.add(scanner.next());
                        System.out.print("Home : ");
                        phoneNos.add(scanner.next());
                        System.out.print("Work : ");
                        phoneNos.add(scanner.next());
                        Contact newContact = new Contact(name, address, phoneNos);
                        jdbc.addRow(conn, newContact, tableName);
                        break;
                    case 5:
                        jdbc.displayTable(conn, tableName);
                        System.out.print("Enter old contact details name : ");
                        String oldName = scanner.next();
                        System.out.print("Address : ");
                        String oldAddress = scanner.next();
                        System.out.print("Enter new contact details name : ");
                        String newName = scanner.next();
                        System.out.print("Address : ");
                        String newAddress = scanner.next();
                        List<String> newPhoneNos = new ArrayList<String>();
                        System.out.print("Mobile : ");
                        newPhoneNos.add(scanner.next());
                        System.out.print("Home : ");
                        newPhoneNos.add(scanner.next());
                        System.out.print("Work : ");
                        newPhoneNos.add(scanner.next());
                        Contact updateContact = new Contact(newName, newAddress, newPhoneNos);
                        jdbc.updateRow(conn, oldName, oldAddress, updateContact, tableName);
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
        }finally{
            jdbc.closeConnection(conn);
        }
    }
}

class JDBCfile {
    static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final String DB_URL = "jdbc:mysql://localhost/";
    
    static final String USER = "root";
    static final String PASS = "";
    
    public Connection getConnectionToDatabase() throws SQLException, Exception{
        Connection conn = null;
        Class.forName(JDBC_DRIVER);
        System.out.println("Connecting to database...");
        conn = DriverManager.getConnection(DB_URL,USER,PASS);
        System.out.println("Connected to database");
        return conn;
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
        System.out.println("Releasing all open resources ...");
        try {
            if (stmt != null) {
                stmt.close();
            }
        } catch (SQLException sqle) {
            sqle.printStackTrace();
        }
    }
    
    public void displayTable(Connection connArg, String tableName) throws SQLException{
        Statement s = connArg.createStatement();
        String selectAll = "SELECT * FROM " + tableName;
        ResultSet rs = s.executeQuery(selectAll);
        while(rs.next()){
            String name = rs.getString("name");
            String address = rs.getString("address");
            int mobile  = rs.getInt("mobile");
            int home = rs.getInt("home");
            int work = rs.getInt("work");
            
            String output = String.format("Name : %s, address : %s, mobile : %d, home : %d, work : %d",name, address, mobile, home, work);
            System.out.println(output);
        }
        closeStatement(s);
    }
    
    public void createDatabase(Connection connArg, String dbName) throws SQLException {
        Statement s = connArg.createStatement();
        s.executeUpdate("DROP DATABASE IF EXISTS "+ dbName);
        String newDatabaseString = "CREATE DATABASE IF NOT EXISTS " + dbName;
        s.executeUpdate(newDatabaseString);
        System.out.println("Created database " + dbName);
        s.executeQuery("USE "+dbName);
        closeStatement(s);
    }
    
    public void createTable(Connection connArg, String tableName) throws SQLException {
        Statement s = connArg.createStatement();
        s.executeUpdate("DROP TABLE IF EXISTS "+ tableName);
        String newTableString = "CREATE TABLE IF NOT EXISTS " + tableName + "(name VARCHAR(50) NOT NULL, address VARCHAR(100) NOT NULL,mobile INT(10), home INT(10), work INT(10), CONSTRAINT ck_name_address PRIMARY KEY(name, address))";
        s.executeUpdate(newTableString);
        System.out.println("Created table " + tableName);
        closeStatement(s);
    }
    
    public void insertValues(Connection conn, Contact[] contacts, String tableName) throws SQLException{
        Statement s = conn.createStatement();
        for(Contact contact: contacts){
            String insert = "INSERT INTO "+tableName+" VALUES (" + contact.toString() + ")";
            System.out.println(insert);
            s.executeUpdate(insert);
        }
        closeStatement(s);
    }
    
    public void selectByName(Connection conn, String name, String tableName)throws SQLException{
        Statement s = conn.createStatement();
        String select = "SELECT name, address, mobile, home, work FROM " + tableName + " WHERE name = \"" + name + "\"";
        ResultSet rs = s.executeQuery(select);
        while(rs.next()){
            String address = rs.getString("address");
            int mobile  = rs.getInt("mobile");
            int home = rs.getInt("home");
            int work = rs.getInt("work");
            
            String output = String.format("Name : %s, address : %s, mobile : %d, home : %d, work : %d",name, address, mobile, home, work);
            System.out.println(output);
        }
        closeStatement(s);
    }

    public void selectByNamePattern(Connection conn, String pattern, String tableName)throws SQLException{
        Statement s = conn.createStatement();
        String select = "SELECT name, address, mobile, home, work FROM " + tableName + " WHERE name LIKE \"%" + pattern + "%\"";
        System.out.println(select);
        ResultSet rs = s.executeQuery(select);
        while(rs.next()){
            String name = rs.getString("name");
            String address = rs.getString("address");
            int mobile  = rs.getInt("mobile");
            int home = rs.getInt("home");
            int work = rs.getInt("work");
            
            String output = String.format("Name : %s, address : %s, mobile : %d, home : %d, work : %d",name, address, mobile, home, work);
            System.out.println(output);
        }
        closeStatement(s);
    }

    public void selectByPhoneNo(Connection conn, String number, String tableName)throws SQLException{
        Statement s = conn.createStatement();
        String select = "SELECT name, address, mobile, home, work FROM " + tableName + " WHERE mobile = \"" + number + "\" OR home = \"" + number +"\" OR work = \"" + number +"\"";
        ResultSet rs = s.executeQuery(select);
        while(rs.next()){
            String name = rs.getString("name");
            String address = rs.getString("address");
            int mobile  = rs.getInt("mobile");
            int home = rs.getInt("home");
            int work = rs.getInt("work");
            
            String output = String.format("Name : %s, address : %s, mobile : %d, home : %d, work : %d",name, address, mobile, home, work);
            System.out.println(output);
        }
        closeStatement(s);
    }
    
    public void addRow(Connection conn, Contact contact, String tableName) throws SQLException{
        Statement s = conn.createStatement();
        String insert = "INSERT INTO "+tableName+" VALUES (" + contact.toString() + ")";
        s.executeUpdate(insert);
        closeStatement(s);
    }
    
    public void updateRow(Connection conn, String oldName, String oldAddress, Contact contact, String tableName) throws SQLException{
        Statement s = conn.createStatement();
        String insert = "UPDATE " + tableName + " SET name = \"" + contact.getName() + "\" ,address = \"" + contact.getAddress();
        List<String> nums = contact.getPhoneNos();
        insert = insert.concat("\" , mobile = " + nums.get(0));
        insert = insert.concat(", home = " + nums.get(1));
        insert = insert.concat(", work = " + nums.get(2) + " WHERE name = \""+ oldName + "\" AND address = \""+ oldAddress+"\"");
        System.out.println(insert);
        s.executeUpdate(insert);
        closeStatement(s);
    }
    
}

class Contact{
    private String name, address;
    private List<String> phoneNos = new ArrayList<String>();
    
    @Override
    public String toString(){
        String output = String.format("\"%s\", \"%s\" ",getName(), getAddress());
        for(String no : getPhoneNos()){
            output = output.concat(", " + no);
        }
        return output;
    }
    
    Contact(String name, String address, List<String> phoneNos){
        this.name = name;
        this.address = address;
        this.phoneNos = phoneNos;
    }
    
    public String getName(){
        return name;
    }
    
    public String getAddress(){
        return address;
    }
    
    public List<String> getPhoneNos(){
        return phoneNos;
    }
    
}