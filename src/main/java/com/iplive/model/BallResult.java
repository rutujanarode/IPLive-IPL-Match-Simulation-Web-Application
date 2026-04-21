package com.iplive.model;

public class BallResult {
    private String over;
    private int runs;
    private boolean isWicket;
    private boolean isFour;
    private boolean isSix;
    private String commentary;
    private int totalRuns;
    private int totalWickets;
    private String totalOver;
    private boolean inningsOver;
    private boolean matchOver;
    private String resultMessage;
    private int striker;
    private int nonStriker;
    private int strikerRuns;
    private int strikerBalls;
    private int nonStrikerRuns;
    private int nonStrikerBalls;
    private String strikerName;
    private String nonStrikerName;

    // getters & setters
    public String getOver()            { return over; }
    public void setOver(String v)      { this.over = v; }
    public int getRuns()               { return runs; }
    public void setRuns(int v)         { this.runs = v; }
    public boolean isWicket()          { return isWicket; }
    public void setWicket(boolean v)   { this.isWicket = v; }
    public boolean isFour()            { return isFour; }
    public void setFour(boolean v)     { this.isFour = v; }
    public boolean isSix()             { return isSix; }
    public void setSix(boolean v)      { this.isSix = v; }
    public String getCommentary()      { return commentary; }
    public void setCommentary(String v){ this.commentary = v; }
    public int getTotalRuns()          { return totalRuns; }
    public void setTotalRuns(int v)    { this.totalRuns = v; }
    public int getTotalWickets()       { return totalWickets; }
    public void setTotalWickets(int v) { this.totalWickets = v; }
    public String getTotalOver()       { return totalOver; }
    public void setTotalOver(String v) { this.totalOver = v; }
    public boolean isInningsOver()     { return inningsOver; }
    public void setInningsOver(boolean v){ this.inningsOver = v; }
    public boolean isMatchOver()       { return matchOver; }
    public void setMatchOver(boolean v){ this.matchOver = v; }
    public String getResultMessage()   { return resultMessage; }
    public void setResultMessage(String v){ this.resultMessage = v; }
    public int getStriker()            { return striker; }
    public void setStriker(int v)      { this.striker = v; }
    public int getNonStriker()         { return nonStriker; }
    public void setNonStriker(int v)   { this.nonStriker = v; }
    public int getStrikerRuns()        { return strikerRuns; }
    public void setStrikerRuns(int v)  { this.strikerRuns = v; }
    public int getStrikerBalls()       { return strikerBalls; }
    public void setStrikerBalls(int v) { this.strikerBalls = v; }
    public int getNonStrikerRuns()     { return nonStrikerRuns; }
    public void setNonStrikerRuns(int v){ this.nonStrikerRuns = v; }
    public int getNonStrikerBalls()    { return nonStrikerBalls; }
    public void setNonStrikerBalls(int v){ this.nonStrikerBalls = v; }
    public String getStrikerName()     { return strikerName; }
    public void setStrikerName(String v){ this.strikerName = v; }
    public String getNonStrikerName()  { return nonStrikerName; }
    public void setNonStrikerName(String v){ this.nonStrikerName = v; }
}
