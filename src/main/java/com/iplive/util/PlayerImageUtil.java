package com.iplive.util;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class PlayerImageUtil {
    private static final HttpClient HTTP_CLIENT = HttpClient.newHttpClient();
    private static final Map<String, String> CACHE = new ConcurrentHashMap<>();

    public static String resolvePlayerImage(String imageUrl, String playerName) {
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            return imageUrl;
        }
        if (playerName == null || playerName.trim().isEmpty()) {
            return null;
        }
        return CACHE.computeIfAbsent(playerName, PlayerImageUtil::fetchWikipediaThumbnail);
    }

    private static String fetchWikipediaThumbnail(String playerName) {
        String title = playerName.trim().replace(' ', '_');
        String apiUrl = "https://en.wikipedia.org/w/api.php?action=query&titles=" + urlEncode(title)
                + "&prop=pageimages&format=json&pithumbsize=300";
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .header("User-Agent", "IPLive/1.0 (https://github.com)")
                    .GET().build();
            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            return extractSourceUrl(response.body());
        } catch (IOException | InterruptedException e) {
            return null;
        }
    }

    private static String extractSourceUrl(String json) {
        if (json == null) return null;
        String token = "\"source\":\"";
        int pos = json.indexOf(token);
        if (pos < 0) return null;
        int start = pos + token.length();
        int end = json.indexOf('"', start);
        if (end < 0) return null;
        return json.substring(start, end).replace("\\/", "/");
    }

    private static String urlEncode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
