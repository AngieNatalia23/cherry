(function () {
    const STORAGE_KEY = 'cherryCarrito';

    const leerCarrito = () => {
        try {
            const valor = sessionStorage.getItem(STORAGE_KEY);
            return valor ? JSON.parse(valor) : [];
        } catch (error) {
            return [];
        }
    };

    let carrito = leerCarrito();
    let productoVistaRapida = null;

    const formatoPrecio = valor => '$' + Number(valor || 0).toLocaleString('es-CO');

    window.toggleCart = function () {
        document.getElementById('side-cart')?.classList.toggle('active');
    };

    window.limpiarCarrito = function () {
        carrito = [];
        sessionStorage.removeItem(STORAGE_KEY);
        actualizarCarrito();
    };

    document.addEventListener('click', function (event) {
        const enlaceLogout = event.target.closest('a[href="/logout"], a[href*="/logout"]');
        if (enlaceLogout) {
            sessionStorage.removeItem(STORAGE_KEY);
        }
    });

    window.agregarCarrito = function (nombre, precio, imagen = '', talla = 'Sin talla') {
        if (!imagen) {
            const boton = document.activeElement;
            const fuente = boton?.closest('.product-card, .product-card-v2')?.querySelector('img')?.getAttribute('src') || '';
            imagen = fuente.startsWith('imagenes/') ? `/static/${fuente}` : fuente;
        }
        const productoExistente = carrito.find(item => item.nombre === nombre && item.talla === talla);
        if (productoExistente) {
            productoExistente.cantidad += 1;
        } else {
            carrito.push({ nombre, precio: Number(precio), imagen, talla, cantidad: 1 });
        }
        actualizarCarrito();
        document.getElementById('side-cart')?.classList.add('active');
    };

    window.cambiarCantidad = function (indice, cambio) {
        carrito[indice].cantidad += cambio;
        if (carrito[indice].cantidad <= 0) carrito.splice(indice, 1);
        actualizarCarrito();
    };

    window.eliminarDelCarrito = function (indice) {
        carrito.splice(indice, 1);
        actualizarCarrito();
    };

    function actualizarCarrito() {
        sessionStorage.setItem(STORAGE_KEY, JSON.stringify(carrito));
        const container = document.getElementById('cart-items-container');
        const totalElement = document.getElementById('cart-total');
        const countElement = document.getElementById('cart-count');
        if (!container) return;

        const total = carrito.reduce((suma, item) => suma + Number(item.precio) * item.cantidad, 0);
        const cantidadTotal = carrito.reduce((suma, item) => suma + item.cantidad, 0);
        if (totalElement) totalElement.textContent = formatoPrecio(total);
        if (countElement) countElement.textContent = cantidadTotal;

        if (!carrito.length) {
            container.innerHTML = '<p class="text-center text-muted py-4">Tu carrito está vacío.</p>';
            return;
        }

        container.innerHTML = carrito.map((item, indice) => `
            <div class="cart-item d-flex gap-2 mb-3 border-bottom pb-3">
                ${item.imagen ? `<img src="${item.imagen}" alt="${item.nombre}">` : ''}
                <div class="flex-grow-1">
                    <h6 class="mb-1">${item.nombre}</h6>
                    <small class="text-muted">Talla: ${item.talla}</small>
                    <div class="d-flex align-items-center justify-content-between mt-2">
                        <span class="fw-bold text-danger">${formatoPrecio(item.precio * item.cantidad)}</span>
                        <div class="btn-group btn-group-sm">
                            <button class="btn btn-outline-secondary" type="button" onclick="cambiarCantidad(${indice}, -1)">-</button>
                            <span class="btn btn-light">${item.cantidad}</span>
                            <button class="btn btn-outline-secondary" type="button" onclick="cambiarCantidad(${indice}, 1)">+</button>
                        </div>
                    </div>
                    <button class="btn btn-link btn-sm text-danger p-0 mt-1" type="button" onclick="eliminarDelCarrito(${indice})">Eliminar</button>
                </div>
            </div>
        `).join('');
    }

    window.llenarModal = function (button) {
        const card = button.closest('.product-card');
        const imagen = button.dataset.image || card?.querySelector('img')?.src || '';
        const nombre = button.dataset.name || card?.querySelector('h6, h3')?.textContent.trim() || '';
        const textoPrecio = card?.querySelector('.current-price, .text-danger')?.textContent || button.dataset.price || '0';
        const precio = Number(String(textoPrecio).replace(/[^0-9]/g, ''));
        productoVistaRapida = { nombre, precio, imagen };

        document.getElementById('qv-img')?.setAttribute('src', imagen);
        document.getElementById('qv-img')?.setAttribute('alt', nombre);
        const nombreElement = document.getElementById('qv-name');
        const precioElement = document.getElementById('qv-price-new');
        if (nombreElement) nombreElement.textContent = nombre;
        if (precioElement) precioElement.textContent = formatoPrecio(precio);

        document.querySelectorAll('.size-btn-modal').forEach((talla, indice) => {
            talla.classList.toggle('active', indice === 0);
            talla.onclick = () => {
                document.querySelectorAll('.size-btn-modal').forEach(item => item.classList.remove('active'));
                talla.classList.add('active');
            };
        });
    };

    document.getElementById('qv-add-to-cart')?.addEventListener('click', () => {
        if (!productoVistaRapida) return;
        const talla = document.querySelector('.size-btn-modal.active')?.textContent.trim() || 'Sin talla';
        agregarCarrito(productoVistaRapida.nombre, productoVistaRapida.precio, productoVistaRapida.imagen, talla);
        const modal = document.getElementById('quickViewModal');
        if (modal && window.bootstrap) bootstrap.Modal.getOrCreateInstance(modal).hide();
    });

    actualizarCarrito();
})();
