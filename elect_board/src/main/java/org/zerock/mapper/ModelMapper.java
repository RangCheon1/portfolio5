package org.zerock.mapper;

import org.apache.ibatis.annotations.Param;
import org.zerock.domain.GraphmapVO;

public interface ModelMapper {
    // 전력 사용량 가져오기(1개월)
    public GraphmapVO getPrevYearUsage(@Param("region") String region, @Param("year") String year);
    // 전력 사용량 가져오기(1~12월)
    GraphmapVO selectMonthlyUsageByYear(@Param("region") String region, @Param("year") int year);
}