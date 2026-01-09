package ch.unige.pinfo1;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Set;

import java.util.HashSet;

import java.time.LocalDateTime;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "events")
@Getter
@Setter
@NoArgsConstructor
public class Event implements Comparable<Event>{

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "event_id")
    public Integer event_id;

    @Column(name = "nom_event")
    public String nom_event;

    @Column(name = "date")
    public LocalDateTime date;

    @Column(name = "description")
    public String description;

    @ElementCollection
    @Column(name = "tags")
    public Set<Tags> tags;

    @ElementCollection
    @Column(name = "organisateurs")
    public Set<Integer> organisateurs; // Id d'une ou plusieurs asso

    @ElementCollection
    @Column(name = "participants")
    public Set<String> participants; // IDs

    @Column(name = "isPrivate")
    public Boolean isPrivate;
    
    public Event(String nom_event, LocalDateTime date, String description, 
                Set<Tags> tags, Set<String> participants, Set<Integer> organisateurs, Boolean isPrivate){
    this.event_id = null;
    this.nom_event = nom_event;
    this.date = date;
    this.description = description;
    this.description = description;
    this.tags = new HashSet<>(tags);
    this.participants = new HashSet<>(participants);
    this.organisateurs = new HashSet<>(organisateurs);
    this.isPrivate = isPrivate;
}

public int compareTo(Event evt) {
    return date.compareTo(evt.date);
}

}
