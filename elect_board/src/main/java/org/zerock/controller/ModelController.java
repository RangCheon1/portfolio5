package org.zerock.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

@Controller
public class ModelController {

    @PostMapping("/modelShort")
    public String predictShort(@RequestParam int cityEncoded,
                               @RequestParam int year,
                               @RequestParam int month,
                               @RequestParam double prevUsage,
                               Model model) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/short";

        Map<String, Object> request = new HashMap<>();
        request.put("city_encoded", cityEncoded);
        request.put("year", year);
        request.put("month", month);
        request.put("prev_usage", prevUsage);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
        String result = "단기 예측 결과: " + response.getBody().get("prediction");
        model.addAttribute("shortResult", result);

        return "test";  // result.jsp로 이동
    }

    @PostMapping("/modelLong")
    public String predictLong(@RequestParam int cityEncoded,
                              @RequestParam int year,
                              @RequestParam int month,
                              Model model) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/long";

        Map<String, Object> request = new HashMap<>();
        request.put("city_encoded", cityEncoded);
        request.put("year", year);
        request.put("month", month);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
        String result = "장기 예측 결과: " + response.getBody().get("prediction");
        model.addAttribute("longResult", result);

        return "test";  // result.jsp로 이동
    }
}


