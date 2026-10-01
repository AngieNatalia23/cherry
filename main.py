# Asegúrate de instalar las dependencias:
# pip install flask pymysql werkzeug
import json

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import pymysql
from werkzeug.security import generate_password_hash, check_password_hash 

app = Flask(__name__)
app.secret_key = 'cherry_secret_key_2026'

# Conexión a la base de datos MySQL (cherry_pro)
def get_db_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='', 
        database='cherry_pro', #aqui esta la base de datos
        cursorclass=pymysql.cursors.DictCursor
    )

# ==========================================
# 1. RUTA PRINCIPAL (Muestra los productos de la base de datos )
# ==========================================
@app.route('/')
def index():
    connection = get_db_connection()
    productos = []
    try:
        with connection.cursor() as cursor:
            query = """
                WITH ProductosFiltrados AS (
                    SELECT 
                        p.id_producto, 
                        p.nombre, 
                        p.precio, 
                        p.imagen, 
                        c.nombre AS categoria,
                        ROW_NUMBER() OVER (PARTITION BY p.id_categoria ORDER BY RAND()) as fila
                    FROM productos p
                    LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
                    WHERE p.estado = 'activo'
                )
                SELECT id_producto, nombre, precio, imagen, categoria
                FROM ProductosFiltrados
                ORDER BY fila ASC, RAND()
                LIMIT 8
            """
            cursor.execute(query)
            productos = cursor.fetchall()
    except Exception as e:
        print(">>> Error al cargar productos:", e)
    finally:

        connection.close()
        
    return render_template('index.html', productos=productos)


# ==========================================
# 2. AUTENTICACIÓN Y USUARIOS
# ==========================================

# --- RUTA DE REGISTRO UNIFICADA ---
from datetime import datetime

# --- RUTA DE REGISTRO
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        nombre_completo = request.form.get('nombre', '').strip()
        correo = request.form.get('correo', '').strip().lower()
        password = request.form.get('password', '').strip()
        
        # Separar el nombre completo en Nombre y Apellido
        partes = nombre_completo.split(' ', 1)
        nombre = partes[0]
        apellido = partes[1] if len(partes) > 1 else ''

        # Encriptar la contraseña
        password_hashed = generate_password_hash(password)

        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # 1. Validar si el correo existe
                cursor.execute("SELECT id_usuario FROM usuario WHERE LOWER(correo) = %s", (correo,))
                if cursor.fetchone():
                    flash('El correo ya está registrado.', 'error')
                    return redirect(url_for('register'))

                # 2. Insertar con los campos EXACTOS de tu tabla
                sql = """
                    INSERT INTO usuario (nombre, apellido, telefono, correo, password, fecha_registro, estado)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """
                # Enviamos telefono como '0000000000', fecha actual y estado 'activo'
                cursor.execute(sql, (
                    nombre, 
                    apellido, 
                    '3000000000', 
                    correo, 
                    password_hashed, 
                    datetime.now(), 
                    'activo'
                ))
                connection.commit()

                flash('¡Registro exitoso! Ya puedes iniciar sesión.', 'success')
                return redirect(url_for('login'))
        except Exception as e:
            print(">>> ERROR MYSQL EXACTO:", e)
            flash('Ocurrió un error al registrar la cuenta.', 'error')
        finally:
            connection.close()

    return render_template('register.html')


# --- RUTA DE LOGIN ---
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        correo = request.form['correo'].strip().lower()
        password = request.form['password'].strip()
        
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM usuario WHERE LOWER(correo) = %s", (correo,))
                user = cursor.fetchone()
                
                # Verificación compatible con contraseña encriptada o plano (para usuarios viejos)
                if user and (check_password_hash(user['password'], password) or user['password'] == password):
                    session['id_usuario'] = user['id_usuario']
                    session['usuario'] = f"{user['nombre']} {user.get('apellido', '')}".strip()
                    
                    # Definimos el rol si existe la columna o evaluamos admin por correo
                    session['rol'] = user.get('rol', 'admin' if correo == 'ana@gmail.com' else 'cliente')
                    
                    flash(f"¡Bienvenido/a de nuevo, {user['nombre']}!", 'success')
                    if session['rol'] == 'admin':
                        return redirect(url_for('admin'))
                    return redirect(url_for('index'))
                else:
                    flash('Correo o contraseña incorrectos.', 'error')
        except Exception as e:
            print(">>> Error en login:", e)
            flash('Error al procesar el inicio de sesión.', 'error')
        finally:
            connection.close()
            
    return render_template('login.html')

#CAMBIO CONTRASEÑA
@app.route('/cambiar-password', methods=['GET', 'POST'])
def cambiar_password():
    if request.method == 'POST':
        correo = request.form.get('correo')
        nueva_password = request.form.get('nueva_password')
        
        conexion = get_db_connection()
        try:
            with conexion.cursor() as cursor:
                # Verificar si el correo existe
                cursor.execute("SELECT * FROM usuario WHERE correo = %s", (correo,))
                usuario = cursor.fetchone()
                
                if usuario:
                    # Actualizar la contraseña directamente en la base de datos
                    cursor.execute(
                        "UPDATE usuario SET password = %s WHERE correo = %s",
                        (nueva_password, correo)
                    )
                    conexion.commit()
                    flash('Contraseña actualizada con éxito. Ya puedes iniciar sesión.', 'success')
                    return redirect(url_for('login'))
                else:
                    flash('El correo electrónico no está registrado.', 'danger')
        finally:
            conexion.close()
            
    return render_template('cambiar_password.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Has cerrado sesión correctamente.', 'info')
    return redirect(url_for('index'))

# =========================================
# 3. CHECKOUT Y FACTURA DINÁMICOS
# ==========================================
@app.route('/checkout')
def checkout():
    # Si el usuario no ha iniciado sesión, lo manda a loguearse
    if 'id_usuario' not in session:
        flash('Debes iniciar sesión para realizar la compra.', 'error')
        return redirect(url_for('login'))
        
    # Consultamos los datos del usuario actual en la base de datos
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        cursor.execute("SELECT nombre, apellido, correo FROM usuario WHERE id_usuario = %s", (session['id_usuario'],))
        usuario = cursor.fetchone()
    conexion.close()

    # Renderizamos la plantilla enviándole el objeto 'usuario'
    return render_template('checkout.html', usuario=usuario)

#FACTURA
@app.route('/factura', methods=['GET', 'POST'])
def factura():
    if request.method == 'POST':
        # 1. Obtener datos del formulario de checkout
        nombre = request.form.get('nombre')
        apellido = request.form.get('apellido')
        direccion = request.form.get('direccion')
        correo = request.form.get('correo')
        metodo_pago = request.form.get('metodo_pago')
        
        id_usuario = session.get('id_usuario')
        connection = get_db_connection()
        id_pedido = None
        productos_carrito = []
        total_pagado = 0

        try:
            with connection.cursor() as cursor:
                # El navegador conserva el carrito para que funcione entre categorías.
                carrito_enviado = request.form.get('carrito_json', '[]')
                try:
                    productos_carrito = json.loads(carrito_enviado)
                    if not isinstance(productos_carrito, list):
                        productos_carrito = []
                except (TypeError, json.JSONDecodeError):
                    productos_carrito = []

                # Compatibilidad con carritos antiguos guardados en MySQL.
                if not productos_carrito:
                    sql_carrito = """
                        SELECT c.id_producto, c.cantidad, p.nombre, p.precio
                        FROM carrito c
                        JOIN productos p ON c.id_producto = p.id_producto
                        WHERE c.id_usuario = %s
                    """
                    cursor.execute(sql_carrito, (id_usuario,))
                    productos_carrito = cursor.fetchall()

                # Si el carrito está vacío, evitamos errores
                if not productos_carrito:
                    flash('Tu carrito está vacío.', 'error')
                    return redirect(url_for('index'))

                # Calcular el total sumando los productos
                for item in productos_carrito:
                    item['precio'] = float(item.get('precio', 0))
                    item['cantidad'] = int(item.get('cantidad', 1))
                    total_pagado += item['precio'] * item['cantidad']

                # 3. Insertar en la tabla 'pedido'
                sql_pedido = "INSERT INTO pedido (id_usuario, direccion, estado) VALUES (%s, %s, %s)"
                cursor.execute(sql_pedido, (id_usuario, direccion, 'pendiente'))
                connection.commit()
                id_pedido = cursor.lastrowid # Obtenemos el ID del pedido recién creado

                # 4. Insertar en la tabla 'factura'
                sql_factura = "INSERT INTO factura (id_pedido, total, metodo_pago) VALUES (%s, %s, %s)"
                cursor.execute(sql_factura, (id_pedido, total_pagado, metodo_pago))
                connection.commit()

                # 5. Guardar cada producto del carrito en la tabla 'detalle_pedido'
                for item in productos_carrito:
                    prod_id = item.get('id_producto') or item.get('id')
                    if not prod_id and item.get('nombre'):
                        cursor.execute(
                            "SELECT id_producto FROM productos WHERE nombre = %s LIMIT 1",
                            (item['nombre'],)
                        )
                        producto = cursor.fetchone()
                        prod_id = producto['id_producto'] if producto else None
                    if not prod_id:
                        continue
                    sql_detalle = """
                        INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) 
                        VALUES (%s, %s, %s, %s)
                    """
                    cursor.execute(sql_detalle, (id_pedido, prod_id, item['cantidad'], item['precio']))
                connection.commit()

                # 6. Opcional: Vaciar el carrito del usuario una vez procesado el pedido
                sql_vaciar = "DELETE FROM carrito WHERE id_usuario = %s"
                cursor.execute(sql_vaciar, (id_usuario,))
                connection.commit()

        except Exception as e:
            print(">>> Error al procesar la factura:", e)
        finally:
            connection.close()

        # 7. Empaquetar los datos para la plantilla
        datos_factura = {
            'id_factura': id_pedido if id_pedido else '0012',
            'cliente': f"{nombre} {apellido}",
            'direccion': direccion,
            'correo': correo,
            'metodo_pago': metodo_pago,
            'total': total_pagado,
            'productos': productos_carrito
        }

        return render_template('factura.html', factura=datos_factura)

    return redirect(url_for('checkout'))


# ==========================================
# 4. PANEL ADMINISTRATIVO (ADMIN)
# ==========================================
@app.route('/admin')
def admin():
    if session.get('rol') != 'admin':
        return redirect(url_for('login'))
        
    connection = get_db_connection()
    productos = []
    pedidos = []
    
    try:
        with connection.cursor() as cursor:
            # 1. Obtener productos para el inventario
            cursor.execute("""
                SELECT p.id_producto, p.nombre, p.precio, p.stock, p.imagen, p.id_categoria,
                       COALESCE(c.nombre, 'Sin Categoría') AS categoria
                FROM productos p
                LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
                WHERE p.estado = 'activo'
            """)
            productos = cursor.fetchall()
            
            # 2. Obtener pedidos recientes usando los nombres reales de tus tablas ('pedido' y 'usuario')
            cursor.execute("""
                SELECT 
                    pe.id_pedido, 
                    u.nombre, 
                    u.apellido, 
                    u.correo, 
                    pe.fecha_pedido AS fecha, 
                    pe.estado,
                    COALESCE(f.total, 0) AS total
                FROM pedido pe
                JOIN usuario u ON pe.id_usuario = u.id_usuario
                LEFT JOIN factura f ON pe.id_pedido = f.id_pedido
                ORDER BY pe.id_pedido DESC
            """)
            pedidos = cursor.fetchall()
            
    except Exception as e:
        print(">>> ERROR EN PANEL ADMIN:", e)
    finally:
        connection.close()
        
    return render_template('admin.html', productos=productos, pedidos=pedidos)


# ==========================================
# 5. GESTION DE PEDIDOS (ADMIN)
# ==========================================
@app.route('/admin/pedido/<int:id_pedido>')
def ver_detalle_pedido(id_pedido):
    if session.get('rol') != 'admin':
        return jsonify({'status': 'error', 'message': 'No autorizado'}), 403

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT direccion FROM pedido WHERE id_pedido = %s",
                (id_pedido,)
            )
            pedido = cursor.fetchone()
            if not pedido:
                return jsonify({'status': 'error', 'message': 'Pedido no encontrado'}), 404

            cursor.execute("""
                SELECT dp.id_detalle, dp.id_producto, dp.cantidad,
                       dp.precio_unitario,
                       (dp.cantidad * dp.precio_unitario) AS subtotal,
                       p.nombre AS producto, p.imagen
                FROM detalle_pedido dp
                LEFT JOIN productos p ON dp.id_producto = p.id_producto
                WHERE dp.id_pedido = %s
                ORDER BY dp.id_detalle
            """, (id_pedido,))
            detalles = cursor.fetchall()
            return jsonify({
                'status': 'success',
                'direccion': pedido['direccion'] or '',
                'detalles': detalles
            })
    except Exception as e:
        print(">>> ERROR AL OBTENER DETALLES:", e)
        return jsonify({'status': 'error', 'message': 'Error al cargar detalles'}), 500
    finally:
        connection.close()


@app.route('/admin/pedido/cambiar_estado', methods=['POST'])
def cambiar_estado_pedido():
    if session.get('rol') != 'admin':
        return jsonify({'status': 'error', 'message': 'No autorizado'}), 403

    id_pedido = request.form.get('id_pedido')
    nuevo_estado = request.form.get('estado')
    estados_validos = {'pendiente', 'enviado', 'entregado'}
    if nuevo_estado not in estados_validos:
        flash('Estado de pedido no válido.', 'danger')
        return redirect(url_for('admin'))

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE pedido SET estado = %s WHERE id_pedido = %s",
                (nuevo_estado, id_pedido)
            )
            connection.commit()
            flash(f'Estado del pedido #{id_pedido} actualizado.', 'success')
    except Exception as e:
        connection.rollback()
        print(">>> ERROR AL CAMBIAR ESTADO:", e)
        flash('Error al cambiar el estado del pedido.', 'danger')
    finally:
        connection.close()

    return redirect(url_for('admin'))


@app.route('/admin/pedido/editar/<int:id_pedido>', methods=['POST'])
def editar_pedido(id_pedido):
    if session.get('rol') != 'admin':
        return jsonify({'status': 'error', 'message': 'No autorizado'}), 403

    direccion = request.form.get('direccion', '').strip()
    try:
        detalles = json.loads(request.form.get('detalles_json', '[]'))
        if not isinstance(detalles, list):
            raise ValueError
    except (TypeError, ValueError, json.JSONDecodeError):
        flash('Los datos de productos del pedido no son válidos.', 'danger')
        return redirect(url_for('admin'))

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE pedido SET direccion = %s WHERE id_pedido = %s",
                (direccion, id_pedido)
            )

            for detalle in detalles:
                id_detalle = detalle.get('id_detalle')
                cantidad = int(detalle.get('cantidad', 0))
                if not id_detalle or cantidad < 0:
                    raise ValueError

                if cantidad == 0:
                    cursor.execute(
                        "DELETE FROM detalle_pedido WHERE id_detalle = %s AND id_pedido = %s",
                        (id_detalle, id_pedido)
                    )
                else:
                    cursor.execute(
                        "UPDATE detalle_pedido SET cantidad = %s WHERE id_detalle = %s AND id_pedido = %s",
                        (cantidad, id_detalle, id_pedido)
                    )

            cursor.execute("""
                SELECT COALESCE(SUM(cantidad * precio_unitario), 0) AS total
                FROM detalle_pedido
                WHERE id_pedido = %s
            """, (id_pedido,))
            total = cursor.fetchone()['total']
            cursor.execute("UPDATE factura SET total = %s WHERE id_pedido = %s", (total, id_pedido))
            connection.commit()
            flash(f'Pedido #{id_pedido} actualizado correctamente.', 'success')
    except (ValueError, TypeError):
        connection.rollback()
        flash('Las cantidades del pedido deben ser números válidos.', 'danger')
    except Exception as e:
        connection.rollback()
        print(">>> ERROR AL EDITAR PEDIDO:", e)
        flash('Error al editar el pedido.', 'danger')
    finally:
        connection.close()

    return redirect(url_for('admin'))


@app.route('/admin/pedido/eliminar/<int:id_pedido>', methods=['POST'])
def eliminar_pedido(id_pedido):
    if session.get('rol') != 'admin':
        return jsonify({'status': 'error', 'message': 'No autorizado'}), 403

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM factura WHERE id_pedido = %s", (id_pedido,))
            cursor.execute("DELETE FROM detalle_pedido WHERE id_pedido = %s", (id_pedido,))
            cursor.execute("DELETE FROM pedido WHERE id_pedido = %s", (id_pedido,))
            connection.commit()
            flash(f'El pedido #{id_pedido} fue eliminado correctamente.', 'success')
    except Exception as e:
        connection.rollback()
        print(">>> ERROR AL ELIMINAR PEDIDO:", e)
        flash('Error al eliminar el pedido.', 'danger')
    finally:
        connection.close()

    return redirect(url_for('admin'))

import os
import re


def secure_filename(filename):
    """Devuelve un nombre seguro para guardar archivos subidos."""
    filename = os.path.basename(filename).strip().replace(' ', '_')
    filename = re.sub(r'[^A-Za-z0-9_.-]', '', filename)
    return filename or 'imagen'

# Configuración opcional para subida de imágenes de productos
UPLOAD_FOLDER = 'static/imagenes'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# ==========================================
# 6. ACCIONES DEL ADMINISTRADOR
# ==========================================

# --- AGREGAR PRODUCTO ---
@app.route('/admin/agregar-producto', methods=['POST'])
def agregar_producto():
    # Validar que el usuario sea Admin
    if session.get('rol') != 'admin':
        flash('Acceso no autorizado.', 'error')
        return redirect(url_for('login'))

    nombre = request.form.get('nombre', '').strip()
    id_categoria = request.form.get('id_categoria')
    precio = request.form.get('precio', 0)
    stock = request.form.get('stock', 10)
    descripcion = request.form.get('descripcion', '').strip()
    
    # Manejar subida de la imagen
    file = request.files.get('imagen')
    nombre_imagen = 'default.jpg'

    if file and file.filename != '':
        filename = secure_filename(file.filename)
        # Asegurar que existe la carpeta estática para imágenes
        os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        nombre_imagen = filename

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO productos (nombre, descripcion, precio, stock, imagen, id_categoria, estado)
                VALUES (%s, %s, %s, %s, %s, %s, 'activo')
            """
            cursor.execute(sql, (nombre, descripcion, precio, stock, nombre_imagen, id_categoria))
            connection.commit()
            flash('¡Producto registrado correctamente!', 'success')
    except Exception as e:
        print(">>> Error al agregar producto:", e)
        flash('Ocurrió un error al guardar el producto.', 'error')
    finally:
        connection.close()

    return redirect(url_for('admin'))

# --- ELIMINAR PRODUCTO ---
@app.route('/admin/eliminar_producto/<int:id_producto>', methods=['POST'])
def eliminar_producto(id_producto):
    if session.get('rol') != 'admin':
        return redirect(url_for('login'))
    
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # Opción A: Eliminación lógica (recomendada para no romper pedidos anteriores)
            cursor.execute("UPDATE productos SET estado = 'inactivo' WHERE id_producto = %s", (id_producto,))
            
            # Opción B: Si realmente quieres borrarlo de la base de datos, usa esta en su lugar:
            # cursor.execute("DELETE FROM productos WHERE id_producto = %s", (id_producto,))
            
            connection.commit()
            flash('Producto eliminado correctamente.', 'success')
    except Exception as e:
        connection.rollback()
        print(">>> ERROR AL ELIMINAR:", e)
        flash('Hubo un error al eliminar el producto.', 'error')
    finally:
        connection.close()
        
    return redirect(url_for('admin'))

# --- EDITAR PRODUCTO ---
@app.route('/admin/editar_producto/<int:id_producto>', methods=['POST'])
def editar_producto(id_producto):
    if session.get('rol') != 'admin':
        return redirect(url_for('login'))
        
    nombre = request.form['nombre']
    precio = request.form['precio']
    stock = request.form['stock']
    id_categoria = request.form['id_categoria']

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE productos 
                SET nombre = %s, precio = %s, stock = %s, id_categoria = %s
                WHERE id_producto = %s
            """, (nombre, precio, stock, id_categoria, id_producto))
            connection.commit()
            flash('Producto actualizado con éxito.', 'success')
    except Exception as e:
        connection.rollback()
        print(">>> ERROR AL EDITAR:", e)
        flash('Error al actualizar el producto.', 'error')
    finally:
        connection.close()

    return redirect(url_for('admin'))

# --- RUTA PARA AGREGAR USUARIO ---
@app.route('/admin/agregar-usuario', methods=['POST'])
def agregar_usuario():
    if session.get('rol') != 'admin':
        flash('Acceso no autorizado.', 'error')
        return redirect(url_for('login'))

    nombre = request.form.get('nombre', '').strip()
    apellido = request.form.get('apellido', '').strip()
    correo = request.form.get('correo', '').strip().lower()
    telefono = request.form.get('telefono', '3000000000').strip()
    password = request.form.get('password', '').strip()
    rol = request.form.get('rol', 'cliente')

    password_hashed = generate_password_hash(password)

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id_usuario FROM usuario WHERE LOWER(correo) = %s", (correo,))
            if cursor.fetchone():
                flash('El correo ingresado ya pertenece a un usuario.', 'error')
                return redirect(url_for('admin'))

            sql = """
                INSERT INTO usuario (nombre, apellido, telefono, correo, password, rol, fecha_registro, estado)
                VALUES (%s, %s, %s, %s, %s, %s, %s, 'activo')
            """
            cursor.execute(sql, (nombre, apellido, telefono, correo, password_hashed, rol, datetime.now()))
            connection.commit()
            flash(f'¡Usuario {nombre} registrado exitosamente!', 'success')
    except Exception as e:
        print(">>> Error al registrar usuario:", e)
        flash('Ocurrió un error al guardar el usuario.', 'error')
    finally:
        connection.close()

    return redirect(url_for('admin'))
#PANEL CLIENTE PERFIL
@app.route('/perfil', methods=['GET', 'POST'])
def perfil():
    # Verificamos si el usuario ha iniciado sesión
    if 'id_usuario' not in session:
        flash('Por favor inicia sesión primero.', 'warning')
        return redirect(url_for('login')) # O tu ruta de acceso

    id_usuario = session['id_usuario']
    conexion = get_db_connection()

    if request.method == 'POST':
        # Si el usuario decide actualizar sus datos o cambiar contraseña
        nuevo_nombre = request.form.get('nombre')
        nueva_contra = request.form.get('password')

        with conexion.cursor() as cursor:
            if nueva_contra: # Si escribió una nueva contraseña, la encriptamos
                hashed_password = generate_password_hash(nueva_contra)
                sql = "UPDATE usuario SET nombre = %s, password = %s WHERE id_usuario = %s"
                cursor.execute(sql, (nuevo_nombre, hashed_password, id_usuario))
            else: # Si solo actualiza el nombre u otros datos
                sql = "UPDATE usuario SET nombre = %s WHERE id_usuario = %s"
                cursor.execute(sql, (nuevo_nombre, id_usuario))
            
            conexion.commit()
        flash('Perfil actualizado con éxito.', 'success')
        return redirect(url_for('perfil'))

    # Obtener los datos actuales del usuario para mostrarlos en la vista
    with conexion.cursor() as cursor:
        cursor.execute("SELECT * FROM usuario WHERE id_usuario = %s", (id_usuario,))
        usuario = cursor.fetchone()

        # Consultar los pedidos que ha hecho este usuario
        cursor.execute("SELECT * FROM pedido WHERE id_usuario = %s", (id_usuario,))
        pedidos = cursor.fetchall()

    conexion.close()
    return render_template('perfil.html', usuario=usuario, pedidos=pedidos)


# VESTIDOS Y FALDAS}
@app.route('/faldas-vestidos')
@app.route('/faldas')
def faldas_vestidos():
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        consulta = "SELECT * FROM productos WHERE id_categoria = 3 AND estado = 'activo'"
        cursor.execute(consulta)
        productos = cursor.fetchall()
    conexion.close()
    
    # 🔍 AGREGA ESTA LÍNEA Y MIRA TU TERMINAL
    print("PRODUCTOS OBTENIDOS:", productos)
    
    return render_template('faldas.html', productos=productos)
# RUTAS DE CATEGORÍAS DE LA TIENDA


@app.route('/camisas')
def camisas():
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        consulta = "SELECT * FROM productos WHERE id_categoria = 1 AND estado = 'activo'"
        cursor.execute(consulta)
        productos = cursor.fetchall()
    conexion.close()
    
    # 🔍 AGREGA ESTA LÍNEA Y MIRA TU TERMINAL
    print("PRODUCTOS OBTENIDOS:", productos)
    
    return render_template('camisas.html', productos=productos)


@app.route('/conjuntos')
def conjuntos():
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        consulta = """
            SELECT p.*, c.nombre AS categoria
            FROM productos p
            LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
            WHERE p.id_categoria = 2 AND p.estado = 'activo'
        """
        cursor.execute(consulta)
        productos = cursor.fetchall()
    conexion.close()

    return render_template('conjuntos.html', productos=productos)

@app.route('/pantalones')
def pantalones():
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        consulta = """
            SELECT * FROM productos
            WHERE id_categoria = 5 AND estado = 'activo'
        """
        cursor.execute(consulta)
        productos = cursor.fetchall()
    conexion.close()

    return render_template('pantalones.html', productos=productos)

@app.route('/zapatos')
def zapatos():
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        consulta = """
            SELECT * FROM productos
            WHERE id_categoria = 6 AND estado = 'activo'
        """
        cursor.execute(consulta)
        productos = cursor.fetchall()
    conexion.close()

    return render_template('zapatos.html', productos=productos)


@app.route('/categoria/<int:id_categoria>')
def ver_categoria(id_categoria):
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        # 1. Obtenemos el nombre de la categoría para que aparezca en el título de la página
        cursor.execute("SELECT nombre FROM categorias WHERE id_categoria = %s", (id_categoria,))
        categoria = cursor.fetchone()
        
        # 2. Consultamos los productos usando la tabla intermedia producto_categoria
        cursor.execute("""
            SELECT p.* FROM productos p
            JOIN producto_categoria pc ON p.id_producto = pc.id_producto
            WHERE pc.id_categoria = %s
        """, (id_categoria,))
        productos = cursor.fetchall()
        
    conexion.close()

    titulo = categoria['nombre'] if categoria else "Colección"
    return render_template('categoria.html', productos=productos, titulo=titulo)
# RUTAS DE PÁGINAS PÚBLICAS (ENLACES DEL FOOTER)
@app.route('/mujer')
def mujer():
    return render_template('mujer.html')

@app.route('/hombre')
def hombre():
    conexion = get_db_connection()
    productos = []
    try:
        with conexion.cursor() as cursor:
            # Opción A: Si la categoría está directamente en la tabla productos
            consulta = """
                SELECT * FROM productos
                WHERE id_categoria = 4 AND estado = 'activo'
            """
            
            # Opción B (Si usas la tabla intermedia producto_categoria):
            # consulta = """
            #     SELECT p.* FROM productos p
            #     JOIN producto_categoria pc ON p.id_producto = pc.id_producto
            #     WHERE pc.id_categoria = 4 AND p.estado = 'activo'
            # """
            
            cursor.execute(consulta)
            productos = cursor.fetchall()
    finally:
        conexion.close()
        
    # ¡Importante! Pasar productos=productos a la plantilla
    return render_template('hombre.html', productos=productos)

@app.route('/ofertas')
def ofertas():
    conexion = get_db_connection()
    with conexion.cursor() as cursor:
        consulta = "SELECT * FROM productos WHERE id_categoria = 8 AND estado = 'activo'"
        cursor.execute(consulta)
        productos_oferta = cursor.fetchall()
    conexion.close()

    return render_template('ofertas.html', productos=productos_oferta)


@app.route('/soporte')
def soporte_center():
    return render_template('soporte.html')

@app.route('/politica-privacidad')
def privacidad():
    return render_template('privacidad.html')

@app.route('/terminos-uso')
def terminos():
    return render_template('terminos.html')
@app.route('/faq')
def faq():
    return render_template('faq.html')

@app.route('/rastreo')
def rastreo():
    return render_template('rastreo.html')

@app.route('/devoluciones')
def devoluciones():
    return render_template('devoluciones.html')

@app.route('/contacto')
def contacto():
    return render_template('contacto.html')

# ==========================================
# 5. INICIALIZADOR DE LA APLICACIÓN
# ==========================================
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)