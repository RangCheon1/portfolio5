package org.zerock.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;
import org.zerock.domain.GraphmapVO;
import org.zerock.mapper.GraphmapMapper;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
public class ApiController {

    @Autowired
    private GraphmapMapper graphmapMapper;

    @GetMapping("/usage/{year}")
    public Map<String, Object> getUsageByRegion(
            @PathVariable("year") int year,
            @RequestParam("region") String region) {

        GraphmapVO data = graphmapMapper.viewByYearAndRegion(year, region);

        Map<String, Object> result = new HashMap<>();
        result.put("region", region);
        result.put("year", year);
        result.put("monthlyUsage", List.of(
                data.getMonth1(), data.getMonth2(), data.getMonth3(),
                data.getMonth4(), data.getMonth5(), data.getMonth6(),
                data.getMonth7(), data.getMonth8(), data.getMonth9(),
                data.getMonth10(), data.getMonth11(), data.getMonth12()
        ));

        return result;
    }
}