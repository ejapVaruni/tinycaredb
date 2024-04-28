import ballerina/http;
import ballerina/sql;

type MapAnyData map<anydata>;

# A service representing a network-accessible API
# bound to port `8089`.
service /sample on new http:Listener(8108) {

    # A resource representing an invokable API method accessible at `/sample/getData/{id}`.
    # This resource is used with path parameters
    #
    # + caller - parameter description  
    # + req - parameter description
    # + return - A string payload which eventually becomes
    # the payload of the response
     // The resource-level CORS config overrides the service-level CORS headers.
    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get patients() returns MyPatient[]|sql:Error {
        return GetAllPatients(); 
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get newbornpatients() returns MyPatient[]|sql:Error {
        return GetAllNewBorns(); 
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get sezuirepatients() returns MyPatient[]|sql:Error {
       return GetSezuirePatients();
    }

    # Description.
    # + return - return value description
    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get sezuirereported()  returns error|int[] {
       return GetSezuireCount();
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get pastsezuirereported()  returns error|int[] {
       return GetSezuirePastCount();
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get malePatients()  returns error|int {
       return MalePercentage();
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get femalePatients()  returns error|int {
       return FemalePercentage();
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: ["*"],
            allowCredentials: true,
            allowHeaders: ["X-Content-Type-Options", "X-PINGOTHER"]
        }
    }
    resource function get getData/[int id](http:Caller caller, http:Request req) returns error? {
        http:Response resp = new;
        Data|error result = GetDataItemById(id);

        if (result is Data) {
          resp.setJsonPayload(result.toJson());
          resp.statusCode = 200;

        } else {
          resp.setJsonPayload(result.toString().toJsonString());
          resp.statusCode = 409;
        }
        resp.setHeader("Content-type", "application/json");
        check caller->respond(resp);
    }
}

public function main() {

  extracted();
  string|sql:Error? errorInCreate = initializeTable();

}

function extracted() {

    sql:Error? errorInInit = initializeDatabase(dbName);
}