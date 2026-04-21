package com.iplive.model;

import java.util.ArrayList;
import java.util.List;

public class Match {
    private int matchId;
    private int teamAId;
    private int teamBId;
    private String teamAName;
    private String teamBName;
    private String teamACode;
    private String teamBCode;
    private String venue;
    private String matchDate;
    private String status;
    private Integer winnerTeamId;
    private String winnerName;

    // Live match state (stored in session)
    private int currentInnings = 1;
    private int runs1 = 0, wickets1 = 0, balls1 = 0;
    private int runs2 = 0, wickets2 = 0, balls2 = 0;
    private int inningsId1 = 0, inningsId2 = 0;
    private List<String> commentary = new ArrayList<>();

    // current batsmen
    private int striker = 0, nonStriker = 1;
    private int[] batterRuns;
    private int[] batterBalls;
    private int currentBowlerIdx = 0;
    private List<Integer> playerIdsBatting = new ArrayList<>();
    private List<Integer> playerIdsBowling = new ArrayList<>();

    public Match() {}

    // Getters & setters
    public int getMatchId()             { return matchId; }
    public void setMatchId(int v)       { this.matchId = v; }
    public int getTeamAId()             { return teamAId; }
    public void setTeamAId(int v)       { this.teamAId = v; }
    public int getTeamBId()             { return teamBId; }
    public void setTeamBId(int v)       { this.teamBId = v; }
    public String getTeamAName()        { return teamAName; }
    public void setTeamAName(String v)  { this.teamAName = v; }
    public String getTeamBName()        { return teamBName; }
    public void setTeamBName(String v)  { this.teamBName = v; }
    public String getTeamACode()        { return teamACode; }
    public void setTeamACode(String v)  { this.teamACode = v; }
    public String getTeamBCode()        { return teamBCode; }
    public void setTeamBCode(String v)  { this.teamBCode = v; }
    public String getVenue()            { return venue; }
    public void setVenue(String v)      { this.venue = v; }
    public String getMatchDate()        { return matchDate; }
    public void setMatchDate(String v)  { this.matchDate = v; }
    public String getStatus()           { return status; }
    public void setStatus(String v)     { this.status = v; }
    public Integer getWinnerTeamId()    { return winnerTeamId; }
    public void setWinnerTeamId(Integer v){ this.winnerTeamId = v; }
    public String getWinnerName()       { return winnerName; }
    public void setWinnerName(String v) { this.winnerName = v; }
    public int getCurrentInnings()      { return currentInnings; }
    public void setCurrentInnings(int v){ this.currentInnings = v; }
    public int getRuns1()               { return runs1; }
    public void setRuns1(int v)         { this.runs1 = v; }
    public int getWickets1()            { return wickets1; }
    public void setWickets1(int v)      { this.wickets1 = v; }
    public int getBalls1()              { return balls1; }
    public void setBalls1(int v)        { this.balls1 = v; }
    public int getRuns2()               { return runs2; }
    public void setRuns2(int v)         { this.runs2 = v; }
    public int getWickets2()            { return wickets2; }
    public void setWickets2(int v)      { this.wickets2 = v; }
    public int getBalls2()              { return balls2; }
    public void setBalls2(int v)        { this.balls2 = v; }
    public int getInningsId1()          { return inningsId1; }
    public void setInningsId1(int v)    { this.inningsId1 = v; }
    public int getInningsId2()          { return inningsId2; }
    public void setInningsId2(int v)    { this.inningsId2 = v; }
    public List<String> getCommentary() { return commentary; }
    public void setCommentary(List<String> v){ this.commentary = v; }
    public void addCommentary(String c) { commentary.add(0, c); if(commentary.size()>20) commentary.remove(commentary.size()-1); }
    public int getStriker()             { return striker; }
    public void setStriker(int v)       { this.striker = v; }
    public int getNonStriker()          { return nonStriker; }
    public void setNonStriker(int v)    { this.nonStriker = v; }
    public int[] getBatterRuns()        { return batterRuns; }
    public void setBatterRuns(int[] v)  { this.batterRuns = v; }
    public int[] getBatterBalls()       { return batterBalls; }
    public void setBatterBalls(int[] v) { this.batterBalls = v; }
    public int getCurrentBowlerIdx()    { return currentBowlerIdx; }
    public void setCurrentBowlerIdx(int v){ this.currentBowlerIdx = v; }
    public List<Integer> getPlayerIdsBatting(){ return playerIdsBatting; }
    public void setPlayerIdsBatting(List<Integer> v){ this.playerIdsBatting = v; }
    public List<Integer> getPlayerIdsBowling(){ return playerIdsBowling; }
    public void setPlayerIdsBowling(List<Integer> v){ this.playerIdsBowling = v; }

    public String getOverString(int balls) {
        return (balls / 6) + "." + (balls % 6);
    }
    public String getCurrentOver() {
        return currentInnings == 1 ? getOverString(balls1) : getOverString(balls2);
    }
    public int getCurrentRuns()    { return currentInnings == 1 ? runs1 : runs2; }
    public int getCurrentWickets() { return currentInnings == 1 ? wickets1 : wickets2; }
    public int getCurrentBalls()   { return currentInnings == 1 ? balls1 : balls2; }
}
