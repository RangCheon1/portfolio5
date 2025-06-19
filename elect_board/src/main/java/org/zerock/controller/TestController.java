package org.zerock.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class TestController {

    @GetMapping("/test")
    public String testPage() {
        return "test"; // /WEB-INF/views/test.jsp로 매핑됨 (ViewResolver 기준)
    }
    @GetMapping("/short")
    public String shortPage() {
        return "short"; // /WEB-INF/views/test.jsp로 매핑됨 (ViewResolver 기준)
    }
}