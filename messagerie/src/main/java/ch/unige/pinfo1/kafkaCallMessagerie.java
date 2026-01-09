package ch.unige.pinfo1;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.microprofile.reactive.messaging.Incoming;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

public class kafkaCallMessagerie {


    @Inject
    MessagerieRepository repositoryMessagerie;

    @Incoming("messagerieMatch")
    @Transactional
    public void newMessKafka(String payload){
        Set<String> ids = new HashSet<>(Arrays.asList(payload.split("££")));
        Messagerie matchMessagerie = new Messagerie(false, false, 2, ids);
        System.out.println(payload);
        repositoryMessagerie.persist(matchMessagerie);
    }
}
