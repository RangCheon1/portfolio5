package org.zerock.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.zerock.domain.GraphmapVO;

@Mapper
public interface GraphmapMapper {
    List<GraphmapVO> view();

    
    GraphmapVO viewByYearAndRegion(@Param("year") int year, @Param("region") String region);
    
}
