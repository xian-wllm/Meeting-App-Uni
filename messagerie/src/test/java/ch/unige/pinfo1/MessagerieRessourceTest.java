package ch.unige.pinfo1;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.oidc.client.OidcTestClient;
import io.quarkus.test.security.TestSecurity;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.containsInAnyOrder;

import java.util.HashSet;
import java.util.Set;

@QuarkusTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class MessagerieRessourceTest {

    @Inject
    kafkaCallMessagerie kafkacall;

    static OidcTestClient oidcTestClient = new OidcTestClient();
    private static Messagerie messagerie1;
    private static Messagerie messagerie1updated;
    private static Messagerie messagerie2;
    private static Message message1;

    @BeforeAll
    @Transactional
    static void setUp(){
      
        MessagerieRepository repositoryMessagerie = new MessagerieRepository();
        repositoryMessagerie.deleteAll();

        MessageRepository repositoryMessage = new MessageRepository();
        repositoryMessage.deleteAll();

        Set<String> participants = new HashSet<String>();
        participants.add("12");
        participants.add("auth0|660312776ea7bff450117ce3");



        messagerie1 = new Messagerie(true, true, participants.size(), participants);
        participants.remove("12");
        messagerie1updated = new Messagerie(true, true, participants.size(), participants);
        participants.add("35");
        participants.add("78");


        messagerie2 = new Messagerie(true, true, participants.size(), participants);

        message1 = new Message("Ceci est un dummy message");
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(1)
    void testCreateMessagerie() {
        given()
          .contentType("application/json")
          .body(messagerie1)
          .when().post("/messagerie")
          .then()
             .statusCode(204);
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(2)
    void testGetMessagerieId() {
      given()
        .when().get("/messagerie/1")
        .then()
           .statusCode(200)
           .body("total_participants", is(2),
        "participants", containsInAnyOrder("12", "auth0|660312776ea7bff450117ce3"));
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(3)
    void testModifMessagerie() {
      given()
        .contentType("application/json")
        .body(messagerie1updated)
        .when().put("/messagerie/1")
        .then()
           .statusCode(204);
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(4)
    void testGetMessagerieIdModified() {
      given()
        .when().get("/messagerie/1")
        .then()
           .statusCode(200)
           .body("total_participants", is(1),
        "participants", containsInAnyOrder("auth0|660312776ea7bff450117ce3"));
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(5)
    void testCreateMessagerie2() {
        given()
          .contentType("application/json")
          .body(messagerie2)
          .when().post("/messagerie")
          .then()
             .statusCode(204);
    }


    @Test
    @TestSecurity(user = "testUser")
    @Order(6)
    void testGetMessagerieUser() {
      given()
        .when().get("/messagerie/user/78")
        .then()
           .statusCode(200)
           .body("$.size()", is(1),
        "total_participants[0]", is(3),
        "participants[0]", containsInAnyOrder("35", "78", "auth0|660312776ea7bff450117ce3"));
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(7)
    void addMessage() {
      given()
        .contentType("application/json")
        .body(message1)
        .when().post("/message/2")
        .then()
           .statusCode(204);
    } 

    @Test
    @TestSecurity(user = "testUser")
    @Order(8)
    void getMessage() {
      given()
        .when().get("/message/1")
        .then()
           .statusCode(200)
           .body("content", is("Ceci est un dummy message"), "sender_id", is(nullValue()));
    } 

    @Test
    @TestSecurity(user = "testUser")
    @Order(9)
    void testDeleteMessagerie() {
        given()
          .contentType("application/json")
          .when().delete("/messagerie/2")
          .then()
             .statusCode(204);
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(10)
    void getMessageNull() {
      given()
        .when().get("/message/2")
        .then()
           .statusCode(204);
          }


    @Test
    @Order(11)
    void addMessage2() {
      given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
        .contentType("application/json")
        .body(message1)
        .when().post("/message/1")
        .then()
           .statusCode(204);

      given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
        .contentType("application/json")
        .body(message1)
        .when().post("/message/1")
        .then()
           .statusCode(204);

      given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
        .contentType("application/json")
        .body(message1)
        .when().post("/message/1")
        .then()
           .statusCode(204);
    } 

    @Test
    @Order(12)
    void getMessOfMessagerie() {
      given().auth().oauth2(getAccessToken("fghryydfd@yahoo.com", "fghryydfd69!"))
        .contentType("application/json")
        .when().get("/message/messagerie/1")
        .then()
           .statusCode(200)
           .body("message_id[2]", is(4), "message_id[1]", is(3), "sender_id[1]", is("auth0|660312776ea7bff450117ce3"));
    } 

    @Test
    @TestSecurity(user = "testUser")
    @Order(13)
    void getMessOfMessagerie403() {
      given()
        .contentType("application/json")
        .body(message1)
        .when().get("/message/messagerie/1")
        .then()
           .statusCode(403);
    } 

    @Test
    @TestSecurity(user = "testUser")
    @Order(14)
    void testDeleteMessage() {
        given()
          .contentType("application/json")
          .body(messagerie2)
          .when().delete("/message/1/2")
          .then()
             .statusCode(204);
    }

    @Test
    @TestSecurity(user = "testUser")
    @Order(15)
    void getMessagesOfMessagerie() {
      given()
        .when().get("/messagerie/1")
        .then() 
          .statusCode(200)
          .body("content", is(nullValue()));
          }

    @Test
    @TestSecurity(user = "testUser")
    @Order(16)
    void testProcessor() {
        kafkacall.newMessKafka("ee££dd");
        given()
        .when().get("/messagerie/3")
        .then()
           .statusCode(200)
           .body("total_participants", is(2));
    }


    private String getAccessToken(String name, String secret) {
      return oidcTestClient.getAccessToken(name, secret);
  }



}