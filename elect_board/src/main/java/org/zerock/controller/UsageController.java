package org.zerock.controller;

import java.util.*;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.zerock.domain.ElectUsageVO;
import org.zerock.service.ElectUsageService;

import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class UsageController {

    @Autowired
    private ElectUsageService usageService;

    @GetMapping("/usageChart")
    public String usageChart(
            @RequestParam(required = false, name = "years") List<String> years,
            @RequestParam(required = false) String region,
            Model model) throws Exception {

        // 선택값이 없으면 초기화 상태로 빈 데이터 전달
        if (years == null || years.isEmpty() || region == null || region.isBlank()) {
            model.addAttribute("chartDataJson", "[]");
            model.addAttribute("allDataMapJson", "{}");
            model.addAttribute("regionList", usageService.getAllRegions());
            model.addAttribute("selectedYears", Collections.emptyList());
            model.addAttribute("selectedRegion", null);
            return "usageChart";
        }

        // 선택값이 있으면 작년 데이터 포함하여 조회 준비
        Set<String> yearsWithPrev = new LinkedHashSet<>(years);
        for (String y : years) {
            try {
                int prevYear = Integer.parseInt(y) - 1;
                if (prevYear >= 2014) {
                    yearsWithPrev.add(String.valueOf(prevYear));
                }
            } catch (NumberFormatException e) {
                // 무시
            }
        }

        List<String> yearsToQuery = new ArrayList<>(yearsWithPrev);
        Collections.sort(yearsToQuery);

        // DB에서 선택된 연도 및 지역의 데이터 조회
        List<ElectUsageVO> usageList = usageService.getUsageByYearsAndRegion(yearsToQuery, region);

        // 월별 데이터 맵 구성
        Map<String, List<Integer>> dataMap = new HashMap<>();
        for (ElectUsageVO vo : usageList) {
            dataMap.put(vo.getYear() + "_" + vo.getRegion(), extractMonthlyData(vo));
        }

        // 현재 선택한 연도 데이터만 필터링 후 맵핑
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

        // 누락된 조합에 null 데이터 추가 (빈 월별 데이터)
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

        // JSON 직렬화
        ObjectMapper mapper = new ObjectMapper();
        String chartDataJson = mapper.writeValueAsString(currentYearData);
        String allDataMapJson = mapper.writeValueAsString(dataMap);

        // 모델에 데이터 전달
        model.addAttribute("chartDataJson", chartDataJson);
        model.addAttribute("allDataMapJson", allDataMapJson);
        model.addAttribute("regionList", usageService.getAllRegions());
        model.addAttribute("selectedYears", years);
        model.addAttribute("selectedRegion", region);

        return "usageChart";
    }

    private List<Integer> extractMonthlyData(ElectUsageVO vo) {
        return List.of(
                vo.getMonth1(), vo.getMonth2(), vo.getMonth3(), vo.getMonth4(),
                vo.getMonth5(), vo.getMonth6(), vo.getMonth7(), vo.getMonth8(),
                vo.getMonth9(), vo.getMonth10(), vo.getMonth11(), vo.getMonth12()
        );
    }
}
