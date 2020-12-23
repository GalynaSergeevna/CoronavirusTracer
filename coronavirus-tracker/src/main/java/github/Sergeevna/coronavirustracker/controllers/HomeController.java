package github.Sergeevna.coronavirustracker.controllers;

import github.Sergeevna.coronavirustracker.models.LocationStats;
import github.Sergeevna.coronavirustracker.services.CoronaVirusDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class HomeController {

    @Autowired
    CoronaVirusDataService CoronaVirusDataService;

    @GetMapping("/")
    public String home(Model model) {
        List<LocationStats> allStats = CoronaVirusDataService.getAllStats();
        int totalReportedCases = allStats.stream().mapToInt(stat -> stat.getLatestTotalCases()).sum();
        int totalNewCases = allStats.stream().mapToInt(stat -> stat.getDiffFromPrevDay()).sum();
        model.addAttribute("locationStats", allStats);
        model.addAttribute("totalReportedCases", totalReportedCases);
        model.addAttribute("totalNewCases", totalNewCases);
        return "home";
    }
}
