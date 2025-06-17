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
            @RequestParam(defaultValue = "all") String region,
            Model model) throws Exception {

        if (years == null || years.isEmpty()) {
            years = List.of("2023");
        }

        // 전력 사용량 데이터 가져오기
        List<ElectUsageVO> usageList = usageService.getUsageByYearsAndRegion(years, region);
        
        // usageList 내용 확인
        System.out.println("usageList: " + usageList);  // usageList 출력
        if (usageList != null) {
            for (ElectUsageVO vo : usageList) {
                // 각 전력 사용량 객체 출력
                System.out.println("Year: " + vo.getYear() + ", Region: " + vo.getRegion());
                System.out.println("Monthly Data: " + vo.getMonth1() + ", " + vo.getMonth2() + ", " +
                                   vo.getMonth3() + ", " + vo.getMonth4() + ", " +
                                   vo.getMonth5() + ", " + vo.getMonth6() + ", " +
                                   vo.getMonth7() + ", " + vo.getMonth8() + ", " +
                                   vo.getMonth9() + ", " + vo.getMonth10() + ", " +
                                   vo.getMonth11() + ", " + vo.getMonth12());
            }
        } else {
            System.out.println("No data found for the given years and region.");
        }

        // region 목록 가져오기
        List<String> regionList = usageService.getAllRegions();

        // 월별 데이터 리스트로 변환
        List<Map<String, Object>> chartData = usageList.stream().map(vo -> {
            Map<String, Object> row = new HashMap<>();
            row.put("year", vo.getYear());
            row.put("region", vo.getRegion());
            row.put("monthlyData", List.of(
                vo.getMonth1(), vo.getMonth2(), vo.getMonth3(), vo.getMonth4(),
                vo.getMonth5(), vo.getMonth6(), vo.getMonth7(), vo.getMonth8(),
                vo.getMonth9(), vo.getMonth10(), vo.getMonth11(), vo.getMonth12()
            ));
            return row;
        }).collect(Collectors.toList());

        // JSON 문자열로 변환
        ObjectMapper mapper = new ObjectMapper();
        String chartDataJson = mapper.writeValueAsString(chartData);

        // 모델에 데이터 추가
        model.addAttribute("chartDataJson", chartDataJson);
        model.addAttribute("regionList", regionList);
        model.addAttribute("selectedYears", years);
        model.addAttribute("selectedRegion", region);

        return "usageChart";
    }
}
