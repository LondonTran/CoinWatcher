String getXAxisLabels(int labelNumber, List<String> times, String graphType) {
  String label;

  switch (graphType) {

    // Thu, Feb 4 2021 7:00 PM --> 7:00PM
    case '1D':
      label = times[labelNumber].substring(16, times[labelNumber].length);
      break;

    // Thu, Feb 4 2021 7:00 PM --> Feb 4
    case '5D':
    case '1M':
    case '1Y':
      label = times[labelNumber].substring(5, times[labelNumber].length - 13);

      break;

    // Thu, Feb 4 2021 7:00 PM --> Feb 4 2021
    case '5Y':
      label = times[labelNumber].substring(5, times[labelNumber].length - 7);
      break;
  }
  return label;
}
