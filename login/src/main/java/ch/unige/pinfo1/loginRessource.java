package ch.unige.pinfo1;

import java.time.LocalDateTime;

import java.util.HashSet;

import java.util.Set;
import org.eclipse.microprofile.jwt.JsonWebToken;

import com.fasterxml.jackson.core.JsonProcessingException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.exceptions.UnirestException;

import io.quarkus.oidc.UserInfo;
import io.quarkus.security.Authenticated;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.json.JsonArray;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;


@Path("/login")
@Transactional
@ApplicationScoped
public class loginRessource {

    @Inject
    JsonWebToken jwt;

    @Inject
    UserInfo userInfo;

    private JsonNode token;
    private LocalDateTime timer = LocalDateTime.now().minusHours(1);

    public JsonNode returnManagementToken(){

        String clientId = System.getenv("OIDC_CLIENT_ID");
        String clientSecret = System.getenv("OIDC_CLIENT_SECRET");
        try {
            HttpResponse<String> response = Unirest.post("https://dev-1ltviw6vq37m8efn.eu.auth0.com/oauth/token")
                .header("content-type", "application/x-www-form-urlencoded")
                .body("grant_type=client_credentials&client_id="+clientId+"&client_secret="+clientSecret+"&audience=https://dev-1ltviw6vq37m8efn.eu.auth0.com/api/v2/")
                .asString();
                ObjectMapper mapper = new ObjectMapper();
                JsonNode node = mapper.readTree(response.getBody());
                return node;

        } catch (UnirestException e) {return null;
        } catch (JsonProcessingException e) {return null;}
    }

    @GET
    @Authenticated
    public String login(){
        return "You are logged in as " + userInfo.getSubject();
    }

    @GET
    @Authenticated
    @Path("/afficherRoles")
    public Set<String> afficherRoles(){
        JsonArray json = userInfo.getJsonObject().getJsonArray("https://quarkus-security.com/roles");
        Set<String> rolesSet = new HashSet<>();

        for (int i = 0; i < json.size(); i++) {
            rolesSet.add(json.getString(i));
        }

        return rolesSet;
    }

    @PUT
    @Path("/getRole")
    @Authenticated
    public String addRole(String role){
        String username = userInfo.getSubject();
        if (timer.isBefore(LocalDateTime.now())) {
            token = returnManagementToken();
            timer = LocalDateTime.now().plusSeconds((long) token.get("expires_in").asInt()-1800);
        }
        try {
            Unirest.post("https://dev-1ltviw6vq37m8efn.eu.auth0.com/api/v2/users/"+username+"/roles")
                .header("content-type", "application/json")
                .header("authorization", "Bearer "+ token.get("access_token").asText() )
                .header("cache-control", "no-cache")
                .body("{ \"roles\": [ \""+role+"\"] }")
                .asString();
                return "Done";
        } catch (UnirestException e) {return "Error";}
    }

    @PUT
    @Path("/deleteRole")
    @Authenticated
    public String deleteRole(String role){
        String username = userInfo.getSubject();
        if (timer.isBefore(LocalDateTime.now())) {
            token = returnManagementToken();
            timer = LocalDateTime.now().plusSeconds((long) token.get("expires_in").asInt()-1800);
        }
        try {
            Unirest.delete("https://dev-1ltviw6vq37m8efn.eu.auth0.com/api/v2/users/"+username+"/roles")
                .header("content-type", "application/json")
                .header("authorization", "Bearer "+ token.get("access_token").asText() )
                .header("cache-control", "no-cache")
                .body("{ \"roles\": [ \""+role+"\"] }")
                .asString();
                return "Done";
        } catch (UnirestException e) {return "Error";}

    }
}
