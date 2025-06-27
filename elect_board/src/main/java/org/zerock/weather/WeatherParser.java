package org.zerock.weather;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.zerock.domain.DailyWeatherVO;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

public class WeatherParser {

    /**
     * JSON 문자열을 파싱하여 날짜별로 존재하는 최대 4일치 예보 정보를 리스트로 변환
     * @param jsonString 단기 예보 JSON 데이터
     * @return DailyWeatherVO 리스트
     * @throws Exception 파싱 중 오류 발생 시 예외
     */
    public List<DailyWeatherVO> parseShortTermForecast(String jsonString) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(jsonString);

        // JSON 경로: response > body > items > item (배열)
        JsonNode items = root.path("response")
                             .path("body")
                             .path("items")
                             .path("item");

        // Map<날짜, Map<카테고리, List<값>>> 형태로 저장
        Map<String, Map<String, List<String>>> dailyCategoryValues = new HashMap<>();

        for (JsonNode item : items) {
            String date = item.get("fcstDate").asText();
            String category = item.get("category").asText();
            String value = item.get("fcstValue").asText();

            dailyCategoryValues.putIfAbsent(date, new HashMap<>());
            Map<String, List<String>> catMap = dailyCategoryValues.get(date);

            catMap.putIfAbsent(category, new ArrayList<>());
            catMap.get(category).add(value);
        }

        List<DailyWeatherVO> result = new ArrayList<>();
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyyMMdd");

        String todayString = LocalDate.now().format(dtf);

        // 날짜 순으로 정렬 후 최대 4일치 처리
        List<String> sortedDates = new ArrayList<>(dailyCategoryValues.keySet());
        sortedDates.sort(Comparator.naturalOrder());

        for (String date : sortedDates.stream().limit(4).collect(Collectors.toList())) {
            Map<String, List<String>> catMap = dailyCategoryValues.get(date);

            List<String> tmxList = catMap.getOrDefault("TMX", Collections.emptyList());
            List<String> tmnList = catMap.getOrDefault("TMN", Collections.emptyList());

            Integer maxTemp = null;
            Integer minTemp = null;

            try {
                if (!tmxList.isEmpty()) {
                    maxTemp = (int) Math.round(Double.parseDouble(tmxList.get(0)));
                }

                if (!tmnList.isEmpty()) {
                    minTemp = (int) Math.round(Double.parseDouble(tmnList.get(0)));
                } else {
                    // 오늘 날짜이면서 TMN이 없을 경우, 0500시 TMP 데이터를 사용
                    if (date.equals(todayString)) {
                        List<String> tmpList = catMap.getOrDefault("TMP", Collections.emptyList());
                        if (!tmpList.isEmpty()) {
                            minTemp = (int) Math.round(Double.parseDouble(tmpList.get(0)));
                        }
                    }
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }

            List<String> skyList = catMap.getOrDefault("SKY", Collections.emptyList());
            String skyCode = getMostFrequentCode(skyList);
            String sky = convertSkyCodeToString(skyCode);

            List<String> ptyList = catMap.getOrDefault("PTY", Collections.emptyList());
            String ptyCode = getMostFrequentCode(ptyList);
            String precipitation = convertPtyCodeToString(ptyCode);

            DailyWeatherVO vo = new DailyWeatherVO();
            vo.setDate(LocalDate.parse(date, dtf).toString()); // yyyy-MM-dd 포맷으로 변환
            vo.setMaxTemperature(maxTemp);
            vo.setMinTemperature(minTemp);
            vo.setSky(sky);
            vo.setPrecipitation(precipitation);

            result.add(vo);
        }

        return result;
    }

    /**
     * 리스트에서 가장 많이 등장한 코드를 반환 (기본값은 "0")
     */
    private String getMostFrequentCode(List<String> codes) {
        if (codes.isEmpty()) return "0";

        Map<String, Long> freqMap = new HashMap<>();
        for (String c : codes) {
            freqMap.put(c, freqMap.getOrDefault(c, 0L) + 1);
        }

        return freqMap.entrySet()
                      .stream()
                      .max(Map.Entry.comparingByValue())
                      .get()
                      .getKey();
    }

    /**
     * SKY 코드 → 날씨 상태 문자열로 변환
     */
    private String convertSkyCodeToString(String code) {
        switch (code) {
            case "1": return "맑음";
            case "3": return "구름많음";
            case "4": return "흐림";
            default: return "알 수 없음";
        }
    }

    /**
     * PTY 코드 → 강수 형태 문자열로 변환
     */
    private String convertPtyCodeToString(String code) {
        switch (code) {
            case "0": return "없음";
            case "1": return "비";
            case "2": return "비/눈";
            case "3": return "눈";
            case "4": return "소나기";
            default: return "알 수 없음";
        }
    }
}
