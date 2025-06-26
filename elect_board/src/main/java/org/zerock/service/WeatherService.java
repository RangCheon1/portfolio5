package org.zerock.service;

import org.springframework.stereotype.Service;
import org.zerock.domain.DailyWeatherVO;
import org.zerock.mapper.WeatherRegionMapper;
import org.zerock.weather.WeatherParser;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Service
public class WeatherService {

    private final String serviceKey = "J48jPOU5eIzIKwIXTfsgu61X%2B2GDkOh5XksElTNFichX2BWkKYB2eSn%2FgBVs8gppi1xZ9pez5qICFPkVwjf4Qw%3D%3D"; // 인코딩된 상태
    private final WeatherParser parser = new WeatherParser();
    private final String baseTime = "0500"; // ✅ 고정된 발표시각

    /**
     * 단기예보 조회
     * @param cityCode 도시코드 (regionMap 키)
     * @param baseDate 조회일자 (yyyyMMdd)
     * @return DailyWeatherVO 리스트
     * @throws Exception
     */
    public List<DailyWeatherVO> getShortTermWeatherVO(int cityCode, String baseDate) throws Exception {
        WeatherRegionMapper.RegionInfo info = WeatherRegionMapper.regionMap.get(cityCode);
        if (info == null) {
            throw new IllegalArgumentException("알 수 없는 도시코드: " + cityCode);
        }

        StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst");
        urlBuilder.append("?" + URLEncoder.encode("serviceKey", StandardCharsets.UTF_8.name()) + "=" + serviceKey);
        urlBuilder.append("&" + URLEncoder.encode("pageNo", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode("1", StandardCharsets.UTF_8.name()));
        urlBuilder.append("&" + URLEncoder.encode("numOfRows", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode("1000", StandardCharsets.UTF_8.name()));
        urlBuilder.append("&" + URLEncoder.encode("dataType", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode("JSON", StandardCharsets.UTF_8.name()));
        urlBuilder.append("&" + URLEncoder.encode("base_date", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode(baseDate, StandardCharsets.UTF_8.name()));
        urlBuilder.append("&" + URLEncoder.encode("base_time", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode(baseTime, StandardCharsets.UTF_8.name()));
        urlBuilder.append("&" + URLEncoder.encode("nx", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode(String.valueOf(info.nx), StandardCharsets.UTF_8.name()));
        urlBuilder.append("&" + URLEncoder.encode("ny", StandardCharsets.UTF_8.name()) + "=" + URLEncoder.encode(String.valueOf(info.ny), StandardCharsets.UTF_8.name()));

        URL url = new URL(urlBuilder.toString());
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Content-type", "application/json");

        int responseCode = conn.getResponseCode();
        BufferedReader rd;
        if (responseCode >= 200 && responseCode <= 300) {
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        } else {
            rd = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
        }

        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = rd.readLine()) != null) {
            sb.append(line);
        }
        rd.close();
        conn.disconnect();

        String response = sb.toString();

        System.out.println("API 응답 원문:");
        System.out.println(response);

        if (responseCode >= 200 && responseCode <= 300) {
            return parser.parseShortTermForecast(response);
        } else {
            throw new RuntimeException("API 요청 실패: 응답코드 " + responseCode + ", 메시지: " + response);
        }
    }
}
