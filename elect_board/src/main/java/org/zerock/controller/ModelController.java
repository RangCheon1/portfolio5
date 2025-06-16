package org.zerock.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

@Controller
public class ModelController {

    @PostMapping(value = "/modelShort", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> predictShortJson(@RequestBody Map<String, Object> request) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/short";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
        Object prediction = response.getBody().get("prediction");

        Map<String, Object> result = new HashMap<>();
        result.put("prediction", prediction);

        return result;
    }

    @PostMapping(value = "/modelLong", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> predictLongJson(@RequestBody Map<String, Object> request) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8000/model/long";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
        Object prediction = response.getBody().get("prediction");

        Map<String, Object> result = new HashMap<>();
        result.put("prediction", prediction);

        return result;
    }
}
