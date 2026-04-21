package com.iplive.model;

public class Player {
    private int playerId;
    private String playerName;
    private int teamId;
    private String teamName;
    private String shortCode;
    private String role;
    private String imageUrl;
    private double battingAvg;
    private double bowlingAvg;
    // season stats
    private int totalRuns;
    private int totalBalls;
    private int totalFours;
    private int totalSixes;
    private int totalWickets;
    private double totalOvers;
    private int totalRunsGiven;
    private int matchesPlayed;

    public Player() {}

    public int getPlayerId()          { return playerId; }
    public void setPlayerId(int v)    { this.playerId = v; }
    public String getPlayerName()     { return playerName; }
    public void setPlayerName(String v){ this.playerName = v; }
    public int getTeamId()            { return teamId; }
    public void setTeamId(int v)      { this.teamId = v; }
    public String getTeamName()       { return teamName; }
    public void setTeamName(String v) { this.teamName = v; }
    public String getShortCode()      { return shortCode; }
    public void setShortCode(String v){ this.shortCode = v; }
    public String getRole()           { return role; }
    public void setRole(String v)     { this.role = v; }
    public String getImageUrl()       { return imageUrl; }
    public void setImageUrl(String v) { this.imageUrl = v; }
    public double getBattingAvg()     { return battingAvg; }
    public void setBattingAvg(double v){ this.battingAvg = v; }
    public double getBowlingAvg()     { return bowlingAvg; }
    public void setBowlingAvg(double v){ this.bowlingAvg = v; }
    public int getTotalRuns()         { return totalRuns; }
    public void setTotalRuns(int v)   { this.totalRuns = v; }
    public int getTotalBalls()        { return totalBalls; }
    public void setTotalBalls(int v)  { this.totalBalls = v; }
    public int getTotalFours()        { return totalFours; }
    public void setTotalFours(int v)  { this.totalFours = v; }
    public int getTotalSixes()        { return totalSixes; }
    public void setTotalSixes(int v)  { this.totalSixes = v; }
    public int getTotalWickets()      { return totalWickets; }
    public void setTotalWickets(int v){ this.totalWickets = v; }
    public double getTotalOvers()     { return totalOvers; }
    public void setTotalOvers(double v){ this.totalOvers = v; }
    public int getTotalRunsGiven()    { return totalRunsGiven; }
    public void setTotalRunsGiven(int v){ this.totalRunsGiven = v; }
    public int getMatchesPlayed()     { return matchesPlayed; }
    public void setMatchesPlayed(int v){ this.matchesPlayed = v; }

    public double getStrikeRate() {
        return totalBalls == 0 ? 0 : Math.round((totalRuns * 100.0 / totalBalls) * 10.0) / 10.0;
    }

    public double getEconomy() {
        return totalOvers == 0 ? 0 : Math.round((totalRunsGiven / totalOvers) * 10.0) / 10.0;
    }
}
