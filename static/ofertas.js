document.addEventListener('DOMContentLoaded', () => {
    window.filterProducts = function(category) {
        category = String(category).toLowerCase();

        document.querySelectorAll('.product-item').forEach(item => {
            const cat = (item.getAttribute('data-category') || '').toLowerCase();
            item.style.display = (category === 'todos' || cat === category) ? '' : 'none';
        });

        document.querySelectorAll('.btn-filter').forEach(btn => {
            btn.classList.toggle('active', btn.textContent.trim().toLowerCase() === category);
        });
    };

    if (window.filterProducts) {
        window.filterProducts('todos');
    }

    const modal = document.getElementById('quickViewModal');
    const qvImg = document.getElementById('qv-img');
    const qvCat = document.getElementById('qv-cat');
    const qvName = document.getElementById('qv-name');
    const qvPriceNew = document.getElementById('qv-price-new');
    const qvPriceOld = document.getElementById('qv-price-old');
    const sizeButtons = document.querySelectorAll('.size-btn');
    let currentProduct = null;

    window.llenarModalOferta = function(button) {
        const name = button.dataset.name;
        const price = Number(button.dataset.price || 0);
        const image = button.dataset.image || '';
        const category = button.closest('.product-item')?.getAttribute('data-category') || 'Oferta';

        currentProduct = { name, price, image, category };

        qvImg.src = image;
        qvImg.alt = name;
        qvCat.textContent = category;
        qvName.textContent = name;
        qvPriceNew.textContent = '$' + Number(price).toLocaleString('es-CO');
        qvPriceOld.textContent = '';

        sizeButtons.forEach(btn => {
            btn.classList.remove('active', 'btn-dark');
            btn.classList.add('btn-outline-dark');
        });
        sizeButtons[0].classList.add('active', 'btn-dark');
        sizeButtons[0].classList.remove('btn-outline-dark');
    };

    sizeButtons.forEach((btn) => {
        btn.addEventListener('click', () => {
            sizeButtons.forEach(item => {
                item.classList.remove('active', 'btn-dark');
                item.classList.add('btn-outline-dark');
            });

            btn.classList.add('active', 'btn-dark');
            btn.classList.remove('btn-outline-dark');
        });
    });

    document.getElementById('qv-add-btn')?.addEventListener('click', () => {
        if (!currentProduct) return;

        const talla = document.querySelector('.size-btn.active')?.textContent.trim() || 'Sin talla';
        agregarCarrito(currentProduct.name, currentProduct.price, currentProduct.image, talla);

        const modalInstance = bootstrap.Modal.getInstance(modal);
        if (modalInstance) modalInstance.hide();
    });
});
