package ch.unige.pinfo1;

public enum Roles {
    AdminAssociations("rol_PdTLOF4mvqz5ozlf"),
    ModoAssociations("rol_bsrbl5d0mqYEnFhT"),
    Organisateur("rol_yQ1EwRuvUKNrKaT5"),
    Modo("rol_LXIf1NN0PuLQ0oyX");

    public final String label;

    private Roles(String label) {
        this.label = label;
    }
}