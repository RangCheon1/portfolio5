package org.zerock.service;

import java.util.List;
import java.util.Map;

import org.zerock.domain.ElectUsageVO;

public interface ElectUsageService {
    List<ElectUsageVO> getUsageByYearsAndRegion(List<String> years, String region);
    List<String> getAllRegions();
}
