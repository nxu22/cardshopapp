module TaxCalculator
    RATES = {
      "Alberta" => { gst: 0.05, pst: 0.0, hst: 0.0 },
      "British Columbia" => { gst: 0.05, pst: 0.07, hst: 0.0 },
      "Manitoba" => { gst: 0.05, pst: 0.07, hst: 0.0 },
      "New Brunswick" => { gst: 0.0, pst: 0.0, hst: 0.15 },
      "Newfoundland and Labrador" => { gst: 0.0, pst: 0.0, hst: 0.15 },
      "Nova Scotia" => { gst: 0.0, pst: 0.0, hst: 0.15 },
      "Ontario" => { gst: 0.0, pst: 0.0, hst: 0.13 },
      "Prince Edward Island" => { gst: 0.0, pst: 0.0, hst: 0.15 },
      "Quebec" => { gst: 0.05, pst: 0.09975, hst: 0.0 },
      "Saskatchewan" => { gst: 0.05, pst: 0.06, hst: 0.0 },
      "Northwest Territories" => { gst: 0.05, pst: 0.0, hst: 0.0 },
      "Nunavut" => { gst: 0.05, pst: 0.0, hst: 0.0 },
      "Yukon" => { gst: 0.05, pst: 0.0, hst: 0.0 }
    }
  
    def self.calculate_tax(total_amount, province)
      province_name = province.is_a?(Province) ? province.name : province
      rates = RATES[province_name]
  
      if rates.nil?
        raise "Tax rates for province #{province_name} not found."
      end
  
      gst = total_amount * rates[:gst]
      pst = total_amount * rates[:pst]
      hst = total_amount * rates[:hst]
      qst = province_name == "Quebec" ? total_amount * rates[:pst] : 0
  
      total_with_taxes = total_amount + gst + pst + hst + qst
  
      return gst, pst, hst, qst, total_with_taxes
    end
  end
  