import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/log;
import ballerina/time;
import ballerina/os;

public type Data record {|
    int Id;
    string Description;
|};

type MyPatient record {|
    readonly int PatientID;
    string Name;
    time:Date DateOfBirth;
    string Gender;
    string ContactInfo;
    boolean FamilyHistory;
|};

//string dbUser = "root";
//string dbPassword = "Myworld@1989";
//string dbName = "defaultdb";
//string dbHost = "localhost";
//string dbPort = "";
os:Error? err = os:setEnv("DB_USER", "avnadmin");
os:Error? err1 = os:setEnv("DB_PASSWORD", "*********");
os:Error? err2 = os:setEnv("DB_NAME", "defaultdb");
os:Error? err3 = os:setEnv("DB_HOST", "mysql-990ca17d-e0a5-4361-8eba-90df4ece0966-tinycare685331494-ch.h.aivencloud.com");
os:Error? err4 = os:setEnv("DB_PORT", "23452");
//string dbUser = os:getEnv("DB_USER");
//string dbPassword = os:getEnv("DB_PASSWORD");
//string dbName = os:getEnv("DB_NAME");
//string dbHost = os:getEnv("DB_HOST");
//string dbPort = os:getEnv("DB_PORT");

public function initializeDatabase(string dbName) returns sql:Error? {
    mysql:Client mysqlClient = check new (dbHost, dbUser, dbPassword, dbPort);
    sql:ParameterizedQuery query = `CREATE DATABASE IF NOT EXISTS ${dbName}` ;
    sql:ExecutionResult result = check mysqlClient->execute(query);
    io:println(result);
    io:println("Database created.");

    check mysqlClient.close();

}

type sqlQuery record {
    
};

function initializeTable() returns string|sql:Error? {
    mysql:Client mysqlClient = check new (dbHost, dbUser, dbPassword, dbPort);
    sql:ParameterizedQuery querydrop1 = `DROP TABLE IF EXISTS Patient` ;
    sql:ParameterizedQuery querydrop2 = `DROP TABLE IF EXISTS Patient` ;
    sql:ParameterizedQuery query2 = `CREATE TABLE IF NOT EXISTS Patient (PatientID INTEGER NOT NULL AUTO_INCREMENT, Name VARCHAR(255), DateOfBirth DATE, Gender ENUM('Male', 'Female', 'Other'), ContactInfo VARCHAR(255), FamilyHistory BOOLEAN, PRIMARY KEY (PatientID))`;
    sql:ParameterizedQuery query3 = `CREATE TABLE IF NOT EXISTS Seizure (SeizureID INTEGER NOT NULL AUTO_INCREMENT, PatientID INT, Date DATE, Time TIME, Duration INT, Description TEXT, Severity ENUM('Low', 'Medium', 'High'), MedicationsAdministered TEXT, RecurrenceRisk ENUM('Low', 'Medium', 'High'), PRIMARY KEY (SeizureID), FOREIGN KEY (PatientID) REFERENCES Patient(PatientID))`;
    sql:ParameterizedQuery query4 = `INSERT INTO Patient (Name, DateOfBirth, Gender, ContactInfo, FamilyHistory)
    SELECT 
        CONCAT('Patient', LPAD(ROW_NUMBER() OVER(), 3, '0')) AS Name,
        DATE_SUB(CURRENT_DATE(), INTERVAL FLOOR(RAND() * 365 * 80) DAY) AS DateOfBirth,
        CASE WHEN RAND() < 0.5 THEN 'Male' ELSE 'Female' END AS Gender,
        CONCAT('contact', LPAD(ROW_NUMBER() OVER(), 3, '0'), '@example.com') AS ContactInfo,
        RAND() < 0.3 AS FamilyHistory
    FROM 
        information_schema.tables`;
    sql:ParameterizedQuery query5 = `INSERT INTO Seizure (PatientID, Date, Time, Duration, Description, Severity, MedicationsAdministered, RecurrenceRisk)
SELECT 
    FLOOR(RAND() * 100) + 1 AS PatientID,
    CURRENT_DATE() AS Date,
    CURRENT_TIME() AS Time,
    FLOOR(RAND() * 20) + 1 AS Duration,
    CONCAT('Description ', LPAD(ROW_NUMBER() OVER(), 3, '0')) AS Description,
    CASE WHEN RAND() < 0.33 THEN 'Low' WHEN RAND() < 0.66 THEN 'Medium' ELSE 'High' END AS Severity,
    CONCAT('Medication ', LPAD(ROW_NUMBER() OVER(), 3, '0')) AS MedicationsAdministered,
    CASE WHEN RAND() < 0.33 THEN 'Low' WHEN RAND() < 0.66 THEN 'Medium' ELSE 'High' END AS RecurrenceRisk
FROM 
    information_schema.tables`;
    sql:ExecutionResult|error resultdrop1 = check mysqlClient->execute(querydrop1);
    io:println("Drop Patient table executed. ", resultdrop1);
    sql:ExecutionResult|error resultdrop2 = check mysqlClient->execute(querydrop2);
    io:println("Drop Patient table executed. ", resultdrop2);
    sql:ExecutionResult|error result1 = check mysqlClient->execute(query2);
    sql:ExecutionResult|error result2 = check mysqlClient->execute(query3);
    sql:ExecutionResult|error result3 = check mysqlClient->execute(query4);
    sql:ExecutionResult|error result4 = check mysqlClient->execute(query5);
    if (resultdrop1 is error) {
        return resultdrop1.message();
    }
    else if (resultdrop2 is error) {
        return resultdrop2.message();
    }
    else if (result1 is error) {
        return result1.message();
    }
    else if (result2 is error) {
        return result2.message();
    }
    else if (result3 is error) {
        return result3.message();
    }
    else if (result4 is error) {
        return result4.message();
    }
    else {
        io:println("Add table executed. ", result1);

        return "Add table successfull";
    }
}

# GetDataItemById - This method is used to get an item from the databae
#
# + id - Id of the data item to retrieve
# + return - Ruturn the added data item if passed, or return error if something failed. 
public function GetDataItemById(int id) returns Data|error {
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL GetDataItemById Method Reached");

    sql:ParameterizedQuery query3 = `SELECT * FROM Patient WHERE PatientID = ${id}`;
    stream<record { }, sql:Error?> resultStream = mysqlClient1->query(query3);
    log:printInfo("SQL GetDataItemById Method Ended");

    record {|
        record { } value;
    |}|error? result = resultStream.next();
    if (result is record {|
                      record { } value;
                  |}) {
        //Map result into structure
        Data addedItem = {
            Id: <int>result.value["PatientID"],
            Description: <string>result.value["Name"]
        };
        return addedItem;

    } else if (result is error) {
        log:printError("Next operation on the stream failed!:" + result.message());
        return error(result.message());
    } else {
        return error("Retreive failed");
    }
}


# Description.
# + return - return value description
public function GetAllPatients() returns MyPatient[]|sql:Error {
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL GetAllPatients Method Reached");

    stream<MyPatient, sql:Error?> resultStream = mysqlClient1->query(`SELECT * FROM Patient`);
    log:printInfo("SQL GetAllPatients Method Ended");

    return check from var patient in resultStream select patient;
}


# GetAllNewBorns - This method is used to get all newborns
#
# + return - Ruturn all the items if passed, or return error if something failed. 
public function GetAllNewBorns() returns MyPatient[]|sql:Error {
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL GetAllNewBorns Method Reached");

    stream<MyPatient, sql:Error?> resultStream = mysqlClient1->query(`SELECT * FROM Patient WHERE DateOfBirth >= DATE_SUB(NOW(),INTERVAL 1 YEAR) and FamilyHistory = 1`);
    log:printInfo("SQL GetAllNewBorns Method Ended");

    return check from var patient in resultStream select patient;
}

# Description.
# + return - return value description
public function GetSezuirePatients() returns MyPatient[]|sql:Error {
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL GetAllPatients Method Reached");

    stream<MyPatient, sql:Error?> resultStream = mysqlClient1->query(`SELECT DISTINCT(Seizure.PatientID), Patient.Name FROM Seizure INNER JOIN Patient ON Seizure.PatientID = Patient.PatientID`);
    log:printInfo("SQL GetAllPatients Method Ended");

    return check from var patient in resultStream select patient;
}

public function GetSezuireCount() returns error|int[]{
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL GetSezuireCount Method Reached");
    int[] ids = [1, 2, 3, 4, 5, 6, 7];
    sql:ParameterizedQuery query = `SELECT COUNT(*) as count FROM Seizure  WHERE YEAR(DATE) = '2024' AND MONTH(Date) in(${ids[0]}, ${ids[1]}, ${ids[2]}, ${ids[3]}, ${ids[4]}, ${ids[5]}, ${ids[6]}) GROUP BY MONTH(Date) ORDER BY MONTH(Date)`;
    stream<record{}, sql:Error?> resultStream = mysqlClient1->query(query);
    int[7] seizureCounts = [1,2,254,4,220,6,7]; // Assuming there are 12 months in a year
    //int[7] seizureCounts = check mysqlClient1->queryRow(query); // Assuming there are 12 months in a year
    return seizureCounts;
}


# Description.
# + return - return value description
public function GetSezuirePastCount() returns error|int[]{
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL GetSezuireCount Method Reached");
    int[] ids = [1, 2, 3, 4, 5, 6, 7];
    sql:ParameterizedQuery query = `SELECT COUNT(*) as count FROM Seizure  WHERE YEAR(DATE) = '2024' AND MONTH(Date) in(${ids[0]}, ${ids[1]}, ${ids[2]}, ${ids[3]}, ${ids[4]}, ${ids[5]}, ${ids[6]}) GROUP BY MONTH(Date) ORDER BY MONTH(Date)`;
    stream<record{}, sql:Error?> resultStream = mysqlClient1->query(query);
    int[7] seizureCounts = [1,2,300,4,225,6,7]; // Assuming there are 12 months in a year
    //int[7] seizureCounts = check mysqlClient1->queryRow(query);
    return seizureCounts;
}

# Description.
# + return - return value description
public function MalePercentage() returns error|int{
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL MalePercentage Method Reached");
    sql:ParameterizedQuery query = `SELECT SUM(r.gender = "male")*100/count(*) as maleP FROM (SELECT DISTINCT(s.PatientID), p.gender FROM Seizure as s INNER JOIN Patient as p ON s.PatientID = p.PatientID) as r`;
    int malePercentage = check mysqlClient1->queryRow(query);
    log:printInfo("SQL MalePercentage Method Ended");

    return malePercentage;
}


# Description.
# + return - return value description
public function FemalePercentage() returns error|int{
    mysql:Client mysqlClient1 = check new (dbHost, dbUser, dbPassword, dbPort);
    log:printInfo("SQL MalePercentage Method Reached");
    sql:ParameterizedQuery query = `SELECT SUM(r.gender = "female")*100/count(*) as maleF FROM (SELECT DISTINCT(s.PatientID), p.gender FROM Seizure as s INNER JOIN Patient as p ON s.PatientID = p.PatientID) as r`;
    int femalePercentage = check mysqlClient1->queryRow(query);
    log:printInfo("SQL MalePercentage Method Ended");

    return femalePercentage;
}