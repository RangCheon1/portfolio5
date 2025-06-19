package org.zerock.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.zerock.domain.GraphmapVO;
import org.zerock.mapper.ModelMapper;

@Service
public class ModelService {

    @Autowired
    private ModelMapper modelMapper;
    
    // 전력 사용량 가져오기(1개월치)
    public Float getPrevYearUsage(String region, int year, int month) {
        String prevYear = String.valueOf(year);

        GraphmapVO vo = modelMapper.getPrevYearUsage(region, prevYear);

        if (vo == null) { // DB 결과 없음
            return null;
        }

        // 해당 월 값 반환
        switch (month) {
            case 1: return (float) vo.getMonth1();
            case 2: return (float) vo.getMonth2();
            case 3: return (float) vo.getMonth3();
            case 4: return (float) vo.getMonth4();
            case 5: return (float) vo.getMonth5();
            case 6: return (float) vo.getMonth6();
            case 7: return (float) vo.getMonth7();
            case 8: return (float) vo.getMonth8();
            case 9: return (float) vo.getMonth9();
            case 10: return (float) vo.getMonth10();
            case 11: return (float) vo.getMonth11();
            case 12: return (float) vo.getMonth12();
            default: return null; // 1~12 이외 잘못된 값
        }
    }
    
    // 전력 사용량 가져오기(1~12월)
    public GraphmapVO getMonthlyUsageByYear(String region, int year) {
        return modelMapper.selectMonthlyUsageByYear(region, year);
    }
}
