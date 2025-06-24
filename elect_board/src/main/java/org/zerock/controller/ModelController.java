package org.zerock.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.GraphmapVO;
import org.zerock.service.ModelService;

@Controller
public class ModelController {

    @Autowired
    private ModelService modelService;

    
    //단기 예측 요청 처리 (FastAPI로 POST 요청)
    @PostMapping(value = "/modelShort", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> predictShortJson(@RequestBody Map<String, Object> request) {

        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/short";

        Map<String, Object> sendData = new HashMap<>();

        try {
            int cityEncoded = Integer.parseInt(request.get("city_encoded").toString());
            int year = Integer.parseInt(request.get("year").toString());
            int month = Integer.parseInt(request.get("month").toString());
            float prevUsage = Float.parseFloat(request.get("prev_usage").toString());

            sendData.put("city_encoded", cityEncoded);
            sendData.put("year", year);
            sendData.put("month", month);
            sendData.put("prev_usage", prevUsage);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid input data format: " + e.getMessage());
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(sendData, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

        Object prediction = null;
        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            prediction = response.getBody().get("prediction");
        } else {
            throw new IllegalStateException("Failed to get prediction from FastAPI");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("prediction", prediction);

        return result;
    }
    

    //장기 예측 요청 처리 (FastAPI로 POST 요청)
    @PostMapping(value = "/modelLong", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> predictLongJson(@RequestBody Map<String, Object> request) {

        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/long";

        Map<String, Object> sendData = new HashMap<>();

        try {
            int cityEncoded = Integer.parseInt(request.get("city_encoded").toString());
            int year = Integer.parseInt(request.get("year").toString());
            int month = Integer.parseInt(request.get("month").toString());

            sendData.put("city_encoded", cityEncoded);
            sendData.put("year", year);
            sendData.put("month", month);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid input data format: " + e.getMessage());
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(sendData, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

        Object prediction = null;
        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            prediction = response.getBody().get("prediction");
        } else {
            throw new IllegalStateException("Failed to get prediction from FastAPI");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("prediction", prediction);

        return result;
    }
    
    // 연간 전체 예측 요청 처리 (FastAPI로 POST 요청)
    @PostMapping(value = "/modelLongYearly", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> predictLongYearlyJson(@RequestBody Map<String, Object> request) {

        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/long/yearly";

        Map<String, Object> sendData = new HashMap<>();

        try {
            int year = Integer.parseInt(request.get("year").toString());
            sendData.put("year", year);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid input data format: " + e.getMessage());
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(sendData, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

        Object predictions = null;
        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            predictions = response.getBody().get("predictions");
        } else {
            throw new IllegalStateException("Failed to get yearly predictions from FastAPI");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("predictions", predictions); // JS가 바로 사용할 수 있게 그대로 반환

        return result;
    }
    
 // 단기 예측 배치 요청 처리 (FastAPI로 POST 요청)
    @PostMapping(value = "/modelShortBatch", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> predictShortBatchJson(@RequestBody Map<String, Object> request) {

        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/short_batch"; // FastAPI 배치 엔드포인트

        // FastAPI에 넘길 데이터 준비
        Object requestsObj = request.get("requests");
        if (requestsObj == null) {
            throw new IllegalArgumentException("Missing 'requests' in request body");
        }

        Map<String, Object> sendData = new HashMap<>();
        sendData.put("requests", requestsObj); // 그대로 넘긴다 (JS에서 이미 배열 형태임)

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(sendData, headers);

        // FastAPI 호출
        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

        Map<String, Object> result = new HashMap<>();
        if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
            result = response.getBody(); // {"predictions": {...}} 형태 그대로 반환
        } else {
            throw new IllegalStateException("Failed to get batch prediction from FastAPI");
        }

        return result;
    }

    
    // 전력 사용량 조회
    @GetMapping("/getPrevUsage")
    @ResponseBody
    public Map<String, Float> getPrevUsage(@RequestParam String region,
                                           @RequestParam int year,
                                           @RequestParam int month) {
        Float usage = modelService.getPrevYearUsage(region, year, month);
        Map<String, Float> map = new HashMap<>();
        map.put("usage", usage);
        return map;
    }
    
    
    // 전력 사용량 조회(1월 ~ 12월)
    @GetMapping("/getPrevAllUsage")
    @ResponseBody
    public Map<String, Object> getPrevAllUsage(@RequestParam String region,
                                               @RequestParam int year) {
        int prevYear = year;
        GraphmapVO vo = modelService.getMonthlyUsageByYear(region, prevYear);

        Map<String, Object> result = new HashMap<>();
        if (vo == null) {
            result.put("usage", new double[0]);
        } else {
            double[] usageArray = new double[] {
                vo.getMonth1(), vo.getMonth2(), vo.getMonth3(), vo.getMonth4(),
                vo.getMonth5(), vo.getMonth6(), vo.getMonth7(), vo.getMonth8(),
                vo.getMonth9(), vo.getMonth10(), vo.getMonth11(), vo.getMonth12()
            };
            result.put("usage", usageArray);
        }
        return result;
    }

}
