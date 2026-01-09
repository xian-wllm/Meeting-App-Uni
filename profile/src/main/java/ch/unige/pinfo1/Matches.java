package ch.unige.pinfo1;


import java.util.Objects;

import jakarta.persistence.Column;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Entity
@Table(name = "matches")
@Getter
@Setter
@NoArgsConstructor
public class Matches {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "matchID")
    public Integer matchID;

    @Column(name = "user_id")
    public String user_id;

    @Column(name = "matched_id")
    public String matched_id;

    @Column(name = "accepted")
    public Boolean accepted;

public Matches(String user_id, String matched_id, Boolean accepted){
    this.user_id = user_id;
    this.matched_id = matched_id;
    this.accepted = accepted;

}

@Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Matches matches = (Matches) o;
        return accepted == matches.accepted &&
                Objects.equals(user_id, matches.user_id) &&
                Objects.equals(matched_id, matches.matched_id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user_id, matched_id, accepted);
    }

}
