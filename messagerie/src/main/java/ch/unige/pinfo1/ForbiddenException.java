package ch.unige.pinfo1;

import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;

public class ForbiddenException extends WebApplicationException {
    public ForbiddenException(String message) {
        super(Response.status(Response.Status.FORBIDDEN)
                      .entity(message)
                      .build());
    }
}
