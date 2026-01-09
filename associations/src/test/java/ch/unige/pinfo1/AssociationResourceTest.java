package ch.unige.pinfo1;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.containsInAnyOrder;

import java.util.EnumSet;
import java.util.HashSet;
import java.util.Set;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import io.quarkus.test.junit.QuarkusTest;
import jakarta.transaction.Transactional;
import io.quarkus.test.security.TestSecurity;

import io.quarkus.test.oidc.client.OidcTestClient;


@QuarkusTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class AssociationResourceTest {

  static OidcTestClient oidcTestClient = new OidcTestClient();
  private static Association asso;
  private static Association asso2;
  

    @BeforeAll
    @Transactional
    static void setUp(){
      
        EnumSet<Tags> tags = EnumSet.noneOf(Tags.class);
        tags.add(Tags.MALE_ALPHA);

        Set<String> mods = new HashSet<String>();
        mods.add("12");
        mods.add("auth0|660312776ea7bff450117ce3");
        
        asso = new Association("AEI", "C'est l'AEI", "img", true, mods, tags);
        asso2 = new Association("AEO", "C'est l'AEO", "img", true, mods, tags);
    }

    @AfterAll
    public static void close() {
      oidcTestClient.close();
    }

  @Test
  @TestSecurity(user = "testUser", roles = {"AdminAssociations"})
  @Order(1)
    void testPostAsso() {
        given()
          .contentType("application/json")
          .body(asso)
          .when().post("/association")
          .then()
             .statusCode(204);
    }
    
  @Test
  @TestSecurity(user = "testUser")
  @Order(2)
    void testGetAssos() {
        given()
          .when().get("/association")
          .then()
             .statusCode(200)
             .body("$.size()", is(1),
                        "name", containsInAnyOrder("AEI"),
                        "description", containsInAnyOrder("C'est l'AEI"));
    }

  @Test
  @Order(3)
  @TestSecurity(user = "testUser")
  void testTagAsso() {
    given()
      .when().get("/association/findByTags/MALE_ALPHA")
      .then()
         .statusCode(200)
         .body("$.size()", is(1),
      "name", containsInAnyOrder("AEI"),
      "tags[0]", containsInAnyOrder("MALE_ALPHA"));
  }

  @Test
  @Order(4)
    void testEditAsso() {
        given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
          .contentType("application/json")
          .body(asso2)
          .when().put("/association/1")
          .then()
             .statusCode(204);
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(5)
    void testGetAssoId() {
        given()
          .when().get("/association/findById/1")
          .then()
             .statusCode(200)
             .body("name", is("AEO"),
                        "description", is("C'est l'AEO"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(6)
    void testGetAssoName() {
        given()
          .when().get("/association/findByName/AEO")
          .then()
             .statusCode(200)
             .body("name", is("AEO"),
                        "description", is("C'est l'AEO"));
    }

  @Test
  @TestSecurity(user = "testUser", roles = {"AdminAssociations"})
  @Order(7)
    void testDeleteAsso() {
        given()
          .contentType("application/json")
          .when().delete("/association/1")
          .then()
             .statusCode(204);
    
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(8)
  void testGetNoAssos() {
      given()
        .when().get("/association")
        .then()
           .statusCode(200)
           .body("$.size()", is(0));
  }

  @Test
  @TestSecurity(user = "testUser", roles = {"AdminAssociations"})
  @Order(9)
    void testPostAsso2() {
        given()
          .contentType("application/json")
          .body(asso)
          .when().post("/association")
          .then()
             .statusCode(204);
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(10)
  void testGetAssosrg() {
      given()
        .when().get("/association")
        .then()
           .statusCode(200)
           .body("$.size()", is(1),
                      "name", containsInAnyOrder("AEI"),
                      "description", containsInAnyOrder("C'est l'AEI"));
  }

  @Test
  @TestSecurity(user = "testUser", roles = {"ModoAssociations"})
  @Order(11)
    void testEditAsso403() {
        given()
          .contentType("application/json")
          .body(asso2)
          .when().put("/association/2")
          .then()
             .statusCode(403);
    }

    private String getAccessToken(String name, String secret) {
      return oidcTestClient.getAccessToken(name, secret);
  }
    
    
}