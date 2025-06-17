package org.zerock.mapper;

import org.apache.ibatis.annotations.Param;
import org.zerock.domain.GraphmapVO;

public interface ModelMapper {
    // region과 year로 전년도 데이터 가져오기
    public GraphmapVO getPrevYearUsage(@Param("region") String region, @Param("year") String year);
}