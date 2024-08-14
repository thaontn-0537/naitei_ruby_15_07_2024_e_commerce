// Menu manipulation
// Add toggle listeners to listen for clicks.
document.addEventListener('turbo:load', function() {
  let account = document.querySelector('#language');
  account.addEventListener('click', function(event) {
    event.preventDefault();
    let menu = document.querySelector('#dropdown-menu');
    menu.classList.toggle('active');
  });
});

document.addEventListener('turbo:load', function() {
  let account = document.querySelector('#account');
  account.addEventListener('click', function(event) {
    event.preventDefault();
    let menu = document.querySelector('#account-dropdown-menu');
    menu.classList.toggle('active');
  });
});
