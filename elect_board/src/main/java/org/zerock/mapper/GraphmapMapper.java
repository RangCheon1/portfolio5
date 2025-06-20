package org.zerock.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.zerock.domain.GraphmapVO;

@Mapper
public interface GraphmapMapper {
    List<GraphmapVO> view();

    
    GraphmapVO viewByYearAndRegion(@Param("year") double year, @Param("region") String region);
    
    List<Map<String, Object>> findTotalUsageByYear(String year);
}
