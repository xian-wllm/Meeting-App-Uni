package ch.unige.pinfo1;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.empty;

import java.util.HashSet;
import java.util.Set;

import org.junit.jupiter.api.BeforeAll;

import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import java.time.LocalDateTime;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.oidc.client.OidcTestClient;
import io.quarkus.test.security.TestSecurity;

import jakarta.transaction.Transactional;

@QuarkusTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class UserRessourceTest {
  static OidcTestClient oidcTestClient = new OidcTestClient();
  private static Utilisateur user1;
  private static Utilisateur user2;

  private static Utilisateur matchUser1; 
  private static Utilisateur matchUser2;
  private static Utilisateur matchUser3;
  private static Utilisateur matchUser4;

  @BeforeAll
  @Transactional
  static void setUp(){

    

    UserRepository repositoryUser = new UserRepository();
    repositoryUser.deleteAll();

    Set<String> blockedUsers = new HashSet<String>(); 
    Set<String> listepp = new HashSet<String>();
    Set<Gender> interests = new HashSet<Gender>(); 
    interests.add(Gender.FEMALE);
    interests.add(Gender.ENBY);

    Set<centerOfInterest> centers = new HashSet<centerOfInterest>(); 
    centers.add(centerOfInterest.ALCOOL);


    user1 = new Utilisateur("us15", "Joan Doe", LocalDateTime.of(1999, 10, 8, 0, 0),"fghryydfd@yahoo.com", new HashSet<>());
    blockedUsers.add(user1.getId());
    user2 = new Utilisateur("us32", null, LocalDateTime.of(2000, 1, 24, 0, 0),
                              "fghryydfd@gmail.com", blockedUsers, true, Color.Rose, "pic", listepp, 
                               Faculte.ECONOMY, Gender.ENBY, interests, "Oui, je suis en effet à l'uni.", centers);


    matchUser1 = new Utilisateur("auth0|66477e9df5c56fa0ab102d9d", "M1", LocalDateTime.of(2000, 1, 24, 0, 0),
    "fghryydfd@gmail.com", blockedUsers, true, Color.Rose, "pic", listepp, 
     Faculte.ECONOMY, Gender.MALE, new HashSet<>(interests), "Oui, je suis en effet à l'uni.", centers);

    interests.remove(Gender.FEMALE);
    
     matchUser2 = new Utilisateur("auth0|66477ec4425d6c86e6638502", "F1", LocalDateTime.of(2000, 1, 24, 0, 0),
    "fghryydfd@gmail.com", blockedUsers, true, Color.Rose, "pic", listepp, 
     Faculte.ECONOMY, Gender.FEMALE, new HashSet<>(interests), "Oui, je suis en effet à l'uni.", centers);

    interests.remove(Gender.FEMALE);
    interests.add(Gender.MALE);

     matchUser3 = new Utilisateur("auth0|66477ed9425d6c86e663850e", "F2", LocalDateTime.of(2000, 1, 24, 0, 0),
    "fghryydfd@gmail.com", blockedUsers, true, Color.Rose, "pic", listepp, 
     Faculte.ECONOMY, Gender.FEMALE, new HashSet<>(interests), "Oui, je suis en effet à l'uni.", centers);

    interests.add(Gender.MALE);
    interests.add(Gender.FEMALE);
    interests.add(Gender.ENBY);

     matchUser4 = new Utilisateur("auth0|66477eed47c62d7f61b12c46", "E1", LocalDateTime.of(2000, 1, 24, 0, 0),
    "fghryydfd@gmail.com", blockedUsers, true, Color.Rose, "pic", listepp, 
     Faculte.ECONOMY, Gender.ENBY, new HashSet<>(interests), "Oui, je suis en effet à l'uni.", centers);
  }


  @Test
  @TestSecurity(user = "testUser")
  @Order(1)
    void testPostUser() {
        given()
          .contentType("application/json")
          .body(user1)
          .when().post("/utilisateur")
          .then()
             .statusCode(204);
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(2)
    void testPostedUser() {
      given()
        .when().get("/utilisateur")
        .then()
          .statusCode(200)
          .body("$.size()", is(1),
        "fullname", containsInAnyOrder("Joan Doe"),
        "email", containsInAnyOrder("fghryydfd@yahoo.com"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(3)
    void testEditUserError() {

      given()
        .contentType("application/json")
        .body(user2)
        .when().put("/utilisateur/profile/us28")
        .then()
           .statusCode(404);
      
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(4)
    void testEditUserProfile() {
        given()
          .contentType("application/json")
          .body(user2)
          .when().put("/utilisateur/profile/us15")
          .then()
            .statusCode(204);
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(5)
    void testgetName() {
        given()
          .when().get("/utilisateur/getName/Joan Doe")
          .then()
             .statusCode(200)
             .body("profilePic", is("pic"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(6)
    void testgetId() {
        given()
          .when().get("/utilisateur/us15")
          .then()
             .statusCode(200)
             .body("fullname", is("Joan Doe"), "gender", is("ENBY"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(7)
    void testDeleteUser() {
        given()
          .contentType("application/json")
          .when().delete("/utilisateur/us15")
          .then()
             .statusCode(204);
    
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(8)
    void testDeletedUser() {
      given()
        .when().get("/utilisateur")
        .then()
           .statusCode(200)
           .body("$.size()", is(0));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(10)
  void testPostMatchUsers() {
    Utilisateur[] matchUsers = {matchUser1, matchUser2, matchUser3, matchUser4};

    for (Utilisateur matchUser : matchUsers) {
        given()
            .contentType("application/json")
            .body(matchUser)
        .when()
            .post("/utilisateur")
        .then()
            .statusCode(204);
    }
    
  }

  @Test
  @TestSecurity(user = "testUser")
  @Order(11)
    void testgetMatches1() {
        given()
          .when().get("/match/potentialMatches/auth0|66477e9df5c56fa0ab102d9d")
          .then()
             .statusCode(200)
             .body("", containsInAnyOrder("auth0|66477ec4425d6c86e6638502", "auth0|66477ed9425d6c86e663850e", "auth0|66477eed47c62d7f61b12c46"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(12)
    void testgetMatches2() {
        given()
          .when().get("/match/potentialMatches/auth0|66477ec4425d6c86e6638502")
          .then()
             .statusCode(200)
             .body("", containsInAnyOrder("auth0|66477eed47c62d7f61b12c46"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(13)
    void testgetMatches3() {
        given()
          .when().get("/match/potentialMatches/auth0|66477eed47c62d7f61b12c46")
          .then()
             .statusCode(200)
             .body("", containsInAnyOrder("auth0|66477e9df5c56fa0ab102d9d", "auth0|66477ec4425d6c86e6638502", "auth0|66477ed9425d6c86e663850e"));
    }

  @Test
  @Order(14)
    void testAcceptMatch() {
        given().auth().oauth2(getAccessToken("MatchUser2@etu.unige.ch", "MatchUser2"))
          .when().post("/match/acceptMatch/auth0|66477eed47c62d7f61b12c46")
          .then()
             .statusCode(200)
             .body("", is(empty()));
    }

  @Test
  @Order(15)
    void testRefuseMatch() {
        given().auth().oauth2(getAccessToken("MatchUser2@etu.unige.ch", "MatchUser2"))
          .when().post("/match/refuseMatch/auth0|66477ed9425d6c86e663850e")
          .then()
             .statusCode(204);
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(16)
    void testGetMatchesOfUser() {
        given()
          .when().get("/match/auth0|66477ec4425d6c86e6638502")
          .then()
             .statusCode(200)
             .body("matched_id", containsInAnyOrder("auth0|66477eed47c62d7f61b12c46", "auth0|66477ed9425d6c86e663850e"),
              "accepted", containsInAnyOrder(true, false));
    }

  @Test
  @Order(17)
    void testAcceptMatchesBoth() {
        given().auth().oauth2(getAccessToken("MatchUser4@etu.unige.ch", "MatchUser4"))
          .when().post("/match/acceptMatch/auth0|66477ec4425d6c86e6638502")
          .then()
             .statusCode(200)
             .body("", containsInAnyOrder("auth0|66477ec4425d6c86e6638502", "auth0|66477eed47c62d7f61b12c46"));
    }

  @Test
  @TestSecurity(user = "testUser")
  @Order(18)
  void testGetMatchesOfUserAgain() {
    given()
      .when().get("/match/auth0|66477eed47c62d7f61b12c46")
      .then()
         .statusCode(200)
         .body("matched_id", containsInAnyOrder("auth0|66477ec4425d6c86e6638502"),
          "accepted", containsInAnyOrder(true));
}

    @Test
    @Order(19)
    @TestSecurity(user = "testUser")
    void testgetall() {
        given()
          .when().get("/match/getAllMatches")
          .then()
             .statusCode(200)
             .body("matched_id", containsInAnyOrder("auth0|66477ed9425d6c86e663850e", "auth0|66477eed47c62d7f61b12c46", "auth0|66477ec4425d6c86e6638502"),
          "accepted", containsInAnyOrder(false, true, true));
    }

    @Test
    @Order(20)
    @TestSecurity(user = "testUser")
    void testdelall() {
        given()
          .when().delete("/match/delAllMatches")
          .then()
             .statusCode(204);
    }


    private String getAccessToken(String name, String secret) {
      return oidcTestClient.getAccessToken(name, secret);
  }

}