package org.zerock.domain;

import lombok.Data;

@Data
public class DailyWeatherVO { 
    private String date;             // yyyy-MM-dd 형식
    private Integer maxTemperature; // 최고기온
    private Integer minTemperature; // 최저기온
    private String sky;              // 맑음, 구름많음, 흐림
    private String precipitation;    // 비, 눈, 없음 등
}