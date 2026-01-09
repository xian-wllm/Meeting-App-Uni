package ch.unige.pinfo1;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
//import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;

import java.util.EnumSet;
import java.util.HashSet;
import java.util.Set;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;



import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.oidc.client.OidcTestClient;
import io.quarkus.test.security.TestSecurity;

import jakarta.transaction.Transactional;

import java.time.LocalDateTime;


@QuarkusTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class EventResourceTest {


    static OidcTestClient oidcTestClient = new OidcTestClient();
    private static Event event1;
    private static Event event2;
    private static EnumSet<Tags> tagsTesting = EnumSet.noneOf(Tags.class);

    @BeforeAll
    @Transactional
    static void setUp(){
        EventRepository repository = new EventRepository();
        repository.deleteAll();

        Set<String> participants = new HashSet<String>();
        participants.add("uid33");
        participants.add("uid55");

        Set<Integer> organisateurs = new HashSet<Integer>();
        organisateurs.add(789);
        organisateurs.add(759);
        
        tagsTesting.add(Tags.INFORMATIQUE);
        tagsTesting.add(Tags.BATTELLE);

        EnumSet<Tags> tags = EnumSet.noneOf(Tags.class);
        tags.add(Tags.MALE_ALPHA);

  
        event1 = new Event("Male", LocalDateTime.now().plusDays(2) ,"Dans le lac vers X", tags, participants, organisateurs, true);
        
        tags.remove(Tags.MALE_ALPHA);
        tags.add(Tags.BATTELLE);

        event2 = new Event("Battelle", LocalDateTime.now().plusDays(2) ,"Autour du lac vers X", tags, participants, organisateurs, true);
    }
  
  
    @Test
    @Order(1)
    @TestSecurity(user = "testUser", roles = {"Organisateur"})
      void testPostEvent() {
          given()
            .contentType("application/json")
            .body(event1)
            .when().post("/event")
            .then()
               .statusCode(204);
      }
  
    @Test
    @Order(2)
    @TestSecurity(user = "testUser")
    void testPostedEvent() {
      given()
        .when().get("/event")
        .then()
           .statusCode(200)
           .body("$.size()", is(1),
        "nom_event", containsInAnyOrder("Male"),
        "tags[0]", containsInAnyOrder("MALE_ALPHA"));
    }


    @Test
    @Order(3)
    @TestSecurity(user = "testUser", roles = {"Organisateur"})
    void testEditEvent() {
        given()
          .contentType("application/json")
          .body(event2)
          .when().put("/event/1")
          .then()
             .statusCode(204);
    }

    @Test
    @Order(4)
    @TestSecurity(user = "testUser")
    void getBadId() {
        given()
          .when().get("/event/15")
          .then()
             .statusCode(204);
    }

    @Test
    @Order(5)
    @TestSecurity(user = "testUser")
    void testAssoEvent() {
      given()
        .when().get("/event/findByAsso/789")
        .then()
           .statusCode(200)
           .body("$.size()", is(1),
        "nom_event", containsInAnyOrder("Battelle"),
        "tags[0]", containsInAnyOrder("BATTELLE"));
    }

    @Test
    @Order(6)
    @TestSecurity(user = "testUser")
    void testTagEvent() {
      given()
        .contentType("application/json")
        .body(tagsTesting)
        .when().post("/event/findByTags")
        .then()
           .statusCode(200)
           .body("$.size()", is(1),
        "nom_event", containsInAnyOrder("Battelle"),
        "tags[0]", containsInAnyOrder("BATTELLE"));
    }

    @Test
    @Order(7)
    @TestSecurity(user = "testUser", roles = {"Organisateur"})
      void testPostEvent2() {
          given()
            .contentType("application/json")
            .body(event2)
            .when().post("/event")
            .then()
               .statusCode(204);
      }

    @Test
    @Order(8)
    @TestSecurity(user = "testUser")
    void testInterestingEvt() {
      given()
        .contentType("application/json")
        .body(tagsTesting)
        .when().post("/event/Interesting/15")
        .then()
           .statusCode(200)
           .body("$.size()", is(2),
        "nom_event", containsInAnyOrder("Battelle", "Battelle"),
        "tags[0]", containsInAnyOrder("BATTELLE"));
    }

    @Test
    @Order(9)
    @TestSecurity(user = "testUser")
    void testInterestingEvt2() {
      given()
        .contentType("application/json")
        .body(tagsTesting)
        .when().post("/event/Interesting/1")
        .then()
           .statusCode(200)
           .body("$.size()", is(1));
    }

    @Test
    @Order(10)
    @TestSecurity(user = "testUser")
    void testInterestingEvt3() {
      tagsTesting.remove(Tags.INFORMATIQUE);
      tagsTesting.remove(Tags.BATTELLE);
      given()
        .contentType("application/json")
        .body(tagsTesting)
        .when().post("/event/Interesting/1")
        .then()
           .statusCode(200)
           .body("$.size()", is(0));
    }

    @Test
    @Order(11)
    @TestSecurity(user = "testUser")
    void testParticipantEvent() {
      given()
        .when().get("/event/findByParticipant/uid33")
        .then()
           .statusCode(200)
           .body("$.size()", is(2),
        "nom_event", containsInAnyOrder("Battelle", "Battelle"),
        "tags[0]", containsInAnyOrder("BATTELLE"));
    }


    @Test
    @Order(12)
    void testInscribe() {
      given().auth().oauth2(getAccessToken("MatchUser2@etu.unige.ch", "MatchUser2"))
          .contentType("application/json")
          .when().put("/event/Inscribe/1")
          .then()
             .statusCode(204);
    }

    @Test
    @Order(13)
    @TestSecurity(user = "testUser")
    void testInscribed() {
      given()
        .when().get("/event/1")
        .then()
           .statusCode(200)
           .body("nom_event", is("Battelle"),
        "participants", containsInAnyOrder("auth0|66477ec4425d6c86e6638502", "uid33", "uid55"));
    }

    @Test
    @Order(14)
    @TestSecurity(user = "testUser", roles = {"Organisateur"})
    void testDeleteEvent() {
        given()
          .contentType("application/json")
          .when().delete("/event/1")
          .then()
             .statusCode(204);
    
    }

    @Test
    @Order(15)
    @TestSecurity(user = "testUser")
    void testDeletedEvent() {
      given()
        .when().get("/event")
        .then()
           .statusCode(200)
           .body("$.size()", is(1));
    }


    private String getAccessToken(String name, String secret) {
      return oidcTestClient.getAccessToken(name, secret);
  }

}