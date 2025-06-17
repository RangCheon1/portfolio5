package org.zerock.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.zerock.domain.ElectUsageVO;
import org.zerock.mapper.ElectUsageMapper;

@Service
public class ElectUsageServiceImpl implements ElectUsageService {

    @Autowired
    private ElectUsageMapper electUsageMapper;

    @Override
    public List<ElectUsageVO> getUsageByYearsAndRegion(List<String> years, String region) {
        Map<String, Object> param = new HashMap<>();
        param.put("yearList", years);
        param.put("region", region);
        return electUsageMapper.getUsageByYear(param);
    }

    @Override
    public List<String> getAllRegions() {
        return electUsageMapper.getAllRegions();
    }
    
}
