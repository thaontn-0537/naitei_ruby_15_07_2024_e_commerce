document.addEventListener("DOMContentLoaded", function() {
  document.getElementById("revenue-time-period-select").addEventListener("change", function() {
    document.getElementById("revenue-time-period-form").submit();
  });

  document.getElementById("selling-time-period-select").addEventListener("change", function() {
    document.getElementById("selling-time-period-form").submit();
  });
});
