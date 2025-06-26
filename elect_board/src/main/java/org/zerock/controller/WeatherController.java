package org.zerock.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.zerock.domain.DailyWeatherVO;
import org.zerock.service.WeatherService;

import java.util.List;

@RestController
@RequestMapping("/weather")
public class WeatherController {

    @Autowired
    private WeatherService weatherService;

    /**
     * 단기예보 조회 (GET)
     * @param citycode 도시 코드
     * @param baseDate 기준일자 (yyyyMMdd)
     * @return DailyWeatherVO 리스트를 JSON으로 반환, 오류 시 500 상태 반환
     */
    @GetMapping("/short")
    public ResponseEntity<List<DailyWeatherVO>> getShortWeather(
            @RequestParam int citycode,
            @RequestParam String baseDate) {

        try {
            List<DailyWeatherVO> data = weatherService.getShortTermWeatherVO(citycode, baseDate);
            return ResponseEntity.ok(data);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }
}
