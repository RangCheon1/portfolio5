package org.zerock.controller;

import org.springframework.web.bind.annotation.RestController;
import org.zerock.domain.ElectUsageVO;
import org.zerock.service.ElectUsageService;
import java.util.Collections;
import java.util.stream.Collectors;
import java.util.ArrayList;
import java.util.Arrays;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

// @Controller 대신 @RestController 써도 되고
@RestController
public class UsageController {

    @Autowired
    private ElectUsageService usageService;

    @GetMapping(value = "/usageChart", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> usageChart(
            @RequestParam(required = false, name = "years") List<String> years,
            @RequestParam(required = false) String region) throws Exception {

        Map<String, Object> result = new HashMap<>();

        // 선택값이 없으면 빈 데이터 반환
        if (years == null || years.isEmpty() || region == null || region.isBlank()) {
            result.put("chartData", Collections.emptyList());
            result.put("allDataMap", Collections.emptyMap());
            result.put("regionList", usageService.getAllRegions());
            result.put("selectedYears", Collections.emptyList());
            result.put("selectedRegion", null);
            return result;
        }

        // 이전년도 포함 등 기존 로직 동일
        Set<String> yearsWithPrev = new LinkedHashSet<>(years);
        for (String y : years) {
            try {
                int prevYear = Integer.parseInt(y) - 1;
                if (prevYear >= 2014) {
                    yearsWithPrev.add(String.valueOf(prevYear));
                }
            } catch (NumberFormatException e) { }
        }

        List<String> yearsToQuery = new ArrayList<>(yearsWithPrev);
        Collections.sort(yearsToQuery);

        List<ElectUsageVO> usageList = usageService.getUsageByYearsAndRegion(yearsToQuery, region);

        Map<String, List<Integer>> dataMap = new HashMap<>();
        for (ElectUsageVO vo : usageList) {
            dataMap.put(vo.getYear() + "_" + vo.getRegion(), extractMonthlyData(vo));
        }

        List<Map<String, Object>> currentYearData = usageList.stream()
                .filter(vo -> years.contains(vo.getYear()))
                .map(vo -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("year", vo.getYear());
                    map.put("region", vo.getRegion());
                    map.put("monthlyData", dataMap.get(vo.getYear() + "_" + vo.getRegion()));
                    return map;
                })
                .collect(Collectors.toList());

        Set<String> presentKeys = currentYearData.stream()
                .map(m -> m.get("year") + "_" + m.get("region"))
                .collect(Collectors.toSet());

        List<String> regionList = "all".equals(region) ? usageService.getAllRegions() : List.of(region);

        for (String y : years) {
            for (String r : regionList) {
                String key = y + "_" + r;
                if (!presentKeys.contains(key)) {
                    Map<String, Object> dummy = new HashMap<>();
                    dummy.put("year", y);
                    dummy.put("region", r);
                    dummy.put("monthlyData", Arrays.asList(null, null, null, null, null, null, null, null, null, null, null, null));
                    currentYearData.add(dummy);
                }
            }
        }

        result.put("chartData", currentYearData);
        result.put("allDataMap", dataMap);
        result.put("regionList", usageService.getAllRegions());
        result.put("selectedYears", years);
        result.put("selectedRegion", region);

        return result;
    }

    private List<Integer> extractMonthlyData(ElectUsageVO vo) {
        return List.of(
                vo.getMonth1(), vo.getMonth2(), vo.getMonth3(), vo.getMonth4(),
                vo.getMonth5(), vo.getMonth6(), vo.getMonth7(), vo.getMonth8(),
                vo.getMonth9(), vo.getMonth10(), vo.getMonth11(), vo.getMonth12()
        );
    }
}