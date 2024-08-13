document.addEventListener('turbo:load', () => {
  let selectedCategories = new Set();
  
  $('.category-link').click(function(e){
    e.preventDefault();
    let categoryId = $(this).data('id');
    
    if (selectedCategories.has(categoryId)) {
      selectedCategories.delete(categoryId);
    } else {
      selectedCategories.add(categoryId);
    }
    $(this).toggleClass('selected');
    
    $.ajax({
      url: '/ajax_products',
      type: 'GET',
      data: {category_ids: Array.from(selectedCategories)},
      dataType: 'script'
    });
  });
});
