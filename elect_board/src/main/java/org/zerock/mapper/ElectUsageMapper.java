package org.zerock.mapper;

import java.util.List;
import java.util.Map;

import org.zerock.domain.ElectUsageVO;

public interface ElectUsageMapper {
    List<ElectUsageVO> getUsageByYear(Map<String, Object> param);
    List<String> getAllRegions();
}
