function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop().split(';').shift();
}

document.addEventListener('turbo:load', () => {
  const checkedCartItemIds = new Set(
    $('input[name="cart_item_checkbox"]:checked')
      .map(function() { return this.value; })
      .get()
  );
  let total = parseInt(getCookie('total')) || 0;
  function updateCartItemsCount() {
    const cartItemsCount = checkedCartItemIds.size;
    document.getElementById('cart_items_count').textContent = cartItemsCount;
    document.getElementById('cart_items_total').textContent = total;
  }
  $('input[name="cart_item_checkbox"]').on('click', function() {
    const value = this.value;
    let priceElement = document.querySelector(`.cart_${this.value}.value`);
    let price = parseInt(priceElement.textContent.trim().replace(/[^0-9.-]+/g, ''), 10);
    if (this.checked) {
      checkedCartItemIds.add(value);
      total += price;
    } else {
      checkedCartItemIds.delete(value);
      total -= price;
    }
    document.cookie = `cartitemids=${JSON.stringify(Array.from(checkedCartItemIds)) || ''}`;
    updateCartItemsCount();
  });
  $('.btn.btn-buy').on('click', function(event) {
    document.cookie = `total=${total}`;
    if (checkedCartItemIds.size == 0) {
      event.preventDefault();
      toastr.error();
    } 
  });  
});

$(document).ready(function() {
  const [navigation] = performance.getEntriesByType('navigation');

  if (navigation && navigation.type === 'reload') {
    document.cookie = `total=0`;
  }
});
