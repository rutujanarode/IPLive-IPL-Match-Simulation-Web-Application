package com.iplive.model;

public class Team {
    private int teamId;
    private String teamName;
    private String shortCode;
    private String homeGround;
    private String colorHex;

    public Team() {}

    public Team(int teamId, String teamName, String shortCode, String homeGround, String colorHex) {
        this.teamId = teamId;
        this.teamName = teamName;
        this.shortCode = shortCode;
        this.homeGround = homeGround;
        this.colorHex = colorHex;
    }

    public int getTeamId()           { return teamId; }
    public void setTeamId(int v)     { this.teamId = v; }
    public String getTeamName()      { return teamName; }
    public void setTeamName(String v){ this.teamName = v; }
    public String getShortCode()     { return shortCode; }
    public void setShortCode(String v){ this.shortCode = v; }
    public String getHomeGround()    { return homeGround; }
    public void setHomeGround(String v){ this.homeGround = v; }
    public String getColorHex()      { return colorHex; }
    public void setColorHex(String v){ this.colorHex = v; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Team team = (Team) o;
        return teamId == team.teamId;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(teamId);
    }
}
