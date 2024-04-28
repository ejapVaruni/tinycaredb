import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerina/log;
import ballerina/time;

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

string dbUser = "root";
string dbPassword = "Myworld@1989";
string dbName = "tiny_care";

public function initializeDatabase(string dbName) returns sql:Error? {
    mysql:Client mysqlClient = check new ("localhost", dbUser, dbPassword);
    sql:ParameterizedQuery query = `CREATE DATABASE IF NOT EXISTS ${dbName}` ;
    sql:ExecutionResult result = check mysqlClient->execute(query);
    io:println(result);
    io:println("Database created.");

    check mysqlClient.close();

}

type sqlQuery record {
    
};

function initializeTable() returns string|sql:Error? {

    mysql:Client mysqlClient = check new ("localhost", dbUser, dbPassword, dbName);
    sql:ParameterizedQuery query1 = `DROP TABLE IF EXISTS SampleData` ;
    sql:ParameterizedQuery query2 = `CREATE TABLE IF NOT EXISTS SampleData (Id INTEGER NOT NULL AUTO_INCREMENT, Description  VARCHAR(300) , PRIMARY KEY (Id))`;
    sql:ExecutionResult|error result = check mysqlClient->execute(query1);
    io:println("Drop table executed. ", result);

    sql:ExecutionResult|error result1 = check mysqlClient->execute(query2);
    if (result1 is error) {
        return result1.message();
    } else {
        io:println("Add table executed. ", result);

        return "Add table successfull";
    }

}

# GetDataItemById - This method is used to get an item from the databae
#
# + id - Id of the data item to retrieve
# + return - Ruturn the added data item if passed, or return error if something failed. 
public function GetDataItemById(int id) returns Data|error {

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
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

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
    log:printInfo("SQL GetAllPatients Method Reached");

    stream<MyPatient, sql:Error?> resultStream = mysqlClient1->query(`SELECT * FROM Patient`);
    log:printInfo("SQL GetAllPatients Method Ended");

    return check from var patient in resultStream select patient;
}


# GetAllNewBorns - This method is used to get all newborns
#
# + return - Ruturn all the items if passed, or return error if something failed. 
public function GetAllNewBorns() returns MyPatient[]|sql:Error {

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
    log:printInfo("SQL GetAllNewBorns Method Reached");

    stream<MyPatient, sql:Error?> resultStream = mysqlClient1->query(`SELECT * FROM Patient WHERE DateOfBirth >= DATE_SUB(NOW(),INTERVAL 1 YEAR) and FamilyHistory = 1`);
    log:printInfo("SQL GetAllNewBorns Method Ended");

    return check from var patient in resultStream select patient;
}

# Description.
# + return - return value description
public function GetSezuirePatients() returns MyPatient[]|sql:Error {

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
    log:printInfo("SQL GetAllPatients Method Reached");

    stream<MyPatient, sql:Error?> resultStream = mysqlClient1->query(`SELECT DISTINCT(Seizure.PatientID), Patient.Name FROM Seizure INNER JOIN Patient ON Seizure.PatientID = Patient.PatientID`);
    log:printInfo("SQL GetAllPatients Method Ended");

    return check from var patient in resultStream select patient;
}

public function GetSezuireCount() returns error|int[]{

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
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

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
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

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
    log:printInfo("SQL MalePercentage Method Reached");
    sql:ParameterizedQuery query = `SELECT SUM(r.gender = "male")*100/count(*) as maleP FROM (SELECT DISTINCT(s.PatientID), p.gender FROM Seizure as s INNER JOIN Patient as p ON s.PatientID = p.PatientID) as r`;
    int malePercentage = check mysqlClient1->queryRow(query);
    log:printInfo("SQL MalePercentage Method Ended");

    return malePercentage;
}


# Description.
# + return - return value description
public function FemalePercentage() returns error|int{

    mysql:Client mysqlClient1 = check new ("localhost", dbUser, dbPassword, dbName);
    log:printInfo("SQL MalePercentage Method Reached");
    sql:ParameterizedQuery query = `SELECT SUM(r.gender = "female")*100/count(*) as maleF FROM (SELECT DISTINCT(s.PatientID), p.gender FROM Seizure as s INNER JOIN Patient as p ON s.PatientID = p.PatientID) as r`;
    int femalePercentage = check mysqlClient1->queryRow(query);
    log:printInfo("SQL MalePercentage Method Ended");

    return femalePercentage;
}