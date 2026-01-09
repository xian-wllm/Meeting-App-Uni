package ch.unige.pinfo1;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.oidc.client.OidcTestClient;

import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasItem;

@QuarkusTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class loginRessourceTest {

    static OidcTestClient oidcTestClient = new OidcTestClient();


    @Test
    @Order(1)
    void testLoginEndpoint() {
        given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
          .when().get("/login")
          .then()
             .statusCode(200)
             .body(is("You are logged in as auth0|660312776ea7bff450117ce3"));
    }

    @Test
    @Order(2)
    void testGetRoles() {
        given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
          .when().get("/login/afficherRoles")
          .then()
             .statusCode(200)
             .body("", hasItem("ModoAssociations"));
    }

    @Test
    @Order(3)
    void testRole() {
        given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
          .contentType("application/json")
          .body(Roles.AdminAssociations.label)
          .when().put("/login/getRole")
          .then()
             .statusCode(200);
    }

    @Test
    @Order(4)
    void testDelRole() {
        given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
          .contentType("application/json")
          .body(Roles.AdminAssociations.label)
          .when().put("/login/deleteRole")
          .then()
             .statusCode(200);
    }

    private String getAccessToken(String name, String secret) {
        return oidcTestClient.getAccessToken(name, secret);
    }
    

}