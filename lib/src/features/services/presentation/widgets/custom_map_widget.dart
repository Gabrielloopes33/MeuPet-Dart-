import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomMapWidget extends StatefulWidget {
  final double centerLatitude;
  final double centerLongitude;
  final double zoom;
  final List<MapMarker> markers;
  final Function(MapMarker)? onMarkerTap;
  final VoidCallback? onMapTap;

  const CustomMapWidget({
    super.key,
    required this.centerLatitude,
    required this.centerLongitude,
    this.zoom = 13.0,
    this.markers = const [],
    this.onMarkerTap,
    this.onMapTap,
  });

  @override
  State<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  double _currentZoom = 13.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _lastScaleValue = 13.0;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.zoom;
  }

  // Converter coordenadas geográficas para pixels na tela
  Offset _latLngToPixel(double lat, double lng, Size size) {
    // Usar Web Mercator projection
    const double mapWidth = 256.0;
    const double mapHeight = 256.0;
    
    // Conversão para coordenadas do mapa
    final x = (lng + 180.0) / 360.0 * mapWidth;
    final latRad = lat * math.pi / 180.0;
    final mercN = math.log(math.tan((math.pi / 4.0) + (latRad / 2.0)));
    final y = (mapHeight / 2.0) - (mapWidth * mercN / (2.0 * math.pi));
    
    // Aplicar zoom e centralizar
    final scale = math.pow(2.0, _currentZoom - 8.0);
    final centerX = (widget.centerLongitude + 180.0) / 360.0 * mapWidth;
    final centerLatRad = widget.centerLatitude * math.pi / 180.0;
    final centerMercN = math.log(math.tan((math.pi / 4.0) + (centerLatRad / 2.0)));
    final centerY = (mapHeight / 2.0) - (mapWidth * centerMercN / (2.0 * math.pi));
    
    final pixelX = (size.width / 2.0) + ((x - centerX) * scale) + _offsetX;
    final pixelY = (size.height / 2.0) + ((y - centerY) * scale) + _offsetY;
    
    return Offset(pixelX, pixelY);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _lastScaleValue = _currentZoom;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Handle zoom
          if (details.scale != 1.0) {
            _currentZoom = (_lastScaleValue * details.scale).clamp(8.0, 20.0);
          }
          
          // Handle pan (only when not zooming)
          if ((details.scale - 1.0).abs() < 0.1) {
            _offsetX += details.focalPointDelta.dx;
            _offsetY += details.focalPointDelta.dy;
          }
        });
      },
      onTap: () {
        widget.onMapTap?.call();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            
            return Stack(
              children: [
                // Fundo do mapa realista - estilo OpenStreetMap
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F8E9), // Fundo verde bem claro
                  ),
                ),
                
                // Padrão de ruas realista
                CustomPaint(
                  size: size,
                  painter: RealisticMapPainter(
                    centerLatitude: widget.centerLatitude,
                    centerLongitude: widget.centerLongitude,
                    zoom: _currentZoom,
                    offsetX: _offsetX,
                    offsetY: _offsetY,
                  ),
                ),
                
                // Markers com posicionamento GPS real
                ...widget.markers.map((marker) {
                  final position = _latLngToPixel(marker.latitude, marker.longitude, size);
                  
                  // Só mostrar markers visíveis na tela
                  if (position.dx < -50 || position.dx > size.width + 50 ||
                      position.dy < -50 || position.dy > size.height + 50) {
                    return const SizedBox.shrink();
                  }
                  
                  return Positioned(
                    left: position.dx - 20,
                    top: position.dy - 40,
                    child: GestureDetector(
                      onTap: () => widget.onMarkerTap?.call(marker),
                      child: _buildMarker(marker),
                    ),
                  );
                }),
                
                // Controles de zoom
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: Column(
                    children: [
                      _buildZoomButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() {
                            _currentZoom = (_currentZoom + 1).clamp(8.0, 18.0);
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildZoomButton(
                        icon: Icons.remove,
                        onPressed: () {
                          setState(() {
                            _currentZoom = (_currentZoom - 1).clamp(8.0, 18.0);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarker(MapMarker marker) {
    return Container(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          // Sombra do marker
          Positioned(
            left: 2,
            top: 2,
            child: Icon(
              Icons.location_on,
              size: 36,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Marker principal
          Icon(
            Icons.location_on,
            size: 36,
            color: marker.color,
          ),
          // Ícone interno
          Positioned.fill(
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  marker.icon,
                  size: 12,
                  color: marker.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Painter para desenhar a grade do mapa
class MapGridPainter extends CustomPainter {
  final double zoom;
  final double offsetX;
  final double offsetY;

  MapGridPainter({
    required this.zoom,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Calcular espaçamento da grade baseado no zoom
    final gridSpacing = (50 * (zoom / 13.0)).clamp(20.0, 100.0);

    // Desenhar grade de fundo
    for (double x = (offsetX % gridSpacing) - gridSpacing; x < size.width + gridSpacing; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = (offsetY % gridSpacing) - gridSpacing; y < size.height + gridSpacing; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Desenhar algumas "ruas" principais
    final mainRoadSpacing = gridSpacing * 3;
    for (double x = (offsetX % mainRoadSpacing) - mainRoadSpacing; x < size.width + mainRoadSpacing; x += mainRoadSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        roadPaint,
      );
    }

    for (double y = (offsetY % mainRoadSpacing) - mainRoadSpacing; y < size.height + mainRoadSpacing; y += mainRoadSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        roadPaint,
      );
    }

    // Adicionar alguns "quarteirões"
    final blockPaint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (double x = (offsetX % (gridSpacing * 2)) - (gridSpacing * 2); 
         x < size.width + (gridSpacing * 2); 
         x += gridSpacing * 4) {
      for (double y = (offsetY % (gridSpacing * 2)) - (gridSpacing * 2); 
           y < size.height + (gridSpacing * 2); 
           y += gridSpacing * 4) {
        if ((x / gridSpacing + y / gridSpacing).floor() % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, gridSpacing * 1.5, gridSpacing * 1.5),
            blockPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter para desenhar um mapa realista
class RealisticMapPainter extends CustomPainter {
  final double centerLatitude;
  final double centerLongitude;
  final double zoom;
  final double offsetX;
  final double offsetY;

  RealisticMapPainter({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.zoom,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStreets(canvas, size);
    _drawLandmarks(canvas, size);
    _drawBounds(canvas, size);
  }

  void _drawStreets(Canvas canvas, Size size) {
    // Ruas normais - amarelo claro (estilo OSM)
    final streetPaint = Paint()
      ..color = const Color(0xFFFFF8DC) // Amarelo bem claro
      ..strokeWidth = 2.5;

    // Avenidas principais - amarelo mais escuro
    final avenuePaint = Paint()
      ..color = const Color(0xFFFFE082) // Amarelo claro
      ..strokeWidth = 5.0;

    final scale = math.pow(2.0, zoom - 10.0);
    final streetSpacing = (50.0 * scale).clamp(20.0, 150.0);

    // Simular ruas baseadas na localização GPS real
    final baseOffsetX = ((centerLongitude + 46.6333) * 2000) % streetSpacing;
    final baseOffsetY = ((centerLatitude + 23.5505) * 2000) % streetSpacing;

    // Primeiro desenhar avenidas principais (mais espessas)
    final avenueSpacing = streetSpacing * 3;
    
    for (double x = (offsetX + baseOffsetX) % avenueSpacing; x < size.width; x += avenueSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), avenuePaint);
    }

    for (double y = (offsetY + baseOffsetY) % avenueSpacing; y < size.height; y += avenueSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), avenuePaint);
    }

    // Bordas das ruas (mais escuras)
    final streetBorderPaint = Paint()
      ..color = const Color(0xFFBDBDBD) // Cinza médio
      ..strokeWidth = 3.5;

    // Bordas das avenidas
    final avenueBorderPaint = Paint()
      ..color = const Color(0xFFF57C00) // Laranja
      ..strokeWidth = 6.0;

    // Desenhar bordas das avenidas
    for (double x = (offsetX + baseOffsetX) % avenueSpacing; x < size.width; x += avenueSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), avenueBorderPaint);
    }

    for (double y = (offsetY + baseOffsetY) % avenueSpacing; y < size.height; y += avenueSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), avenueBorderPaint);
    }

    // Desenhar bordas das ruas
    for (double x = (offsetX + baseOffsetX) % streetSpacing; x < size.width; x += streetSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetBorderPaint);
    }

    for (double y = (offsetY + baseOffsetY) % streetSpacing; y < size.height; y += streetSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetBorderPaint);
    }

    // Depois desenhar ruas menores por cima
    for (double x = (offsetX + baseOffsetX) % streetSpacing; x < size.width; x += streetSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        streetPaint,
      );
    }

    for (double y = (offsetY + baseOffsetY) % streetSpacing; y < size.height; y += streetSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        streetPaint,
      );
    }
  }

  void _drawLandmarks(Canvas canvas, Size size) {
    final scale = math.pow(2.0, zoom - 8.0);
    final blockSize = (60.0 * scale).clamp(30.0, 120.0);

    // Quarteirões residenciais - cinza médio
    final buildingPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;

    // Parques e áreas verdes - verde mais forte
    final parkPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;

    // Edifícios comerciais - rosa claro
    final commercialPaint = Paint()
      ..color = const Color(0xFFF8BBD9)
      ..style = PaintingStyle.fill;

    final blocksX = (size.width / blockSize).ceil() + 2;
    final blocksY = (size.height / blockSize).ceil() + 2;

    for (int i = -1; i < blocksX; i++) {
      for (int j = -1; j < blocksY; j++) {
        final x = i * blockSize + (offsetX % blockSize);
        final y = j * blockSize + (offsetY % blockSize);
        
        if (x > -blockSize && x < size.width + blockSize && 
            y > -blockSize && y < size.height + blockSize) {
          
          // Usar coordenadas GPS para determinar tipo de área
          final blockLat = centerLatitude + ((j - blocksY / 2) * 0.0005);
          final blockLng = centerLongitude + ((i - blocksX / 2) * 0.0005);
          final seed = ((blockLat * blockLng * 100000).abs() % 10).toInt();
          
          Paint paint;
          if (seed < 2) {
            paint = parkPaint; // 20% parques
          } else if (seed < 4) {
            paint = commercialPaint; // 20% comercial
          } else {
            paint = buildingPaint; // 60% residencial
          }
          
          // Desenhar o quarteirão com bordas arredondadas
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 2, y + 2, blockSize - 4, blockSize - 4),
              const Radius.circular(4),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawBounds(Canvas canvas, Size size) {
    // Fundo para o texto de informações
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 140, 55),
        const Radius.circular(8),
      ),
      backgroundPaint,
    );

    // Desenhar informações de localização
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'São Paulo, SP\nLat: ${centerLatitude.toStringAsFixed(3)}\nLng: ${centerLongitude.toStringAsFixed(3)}\nZoom: ${zoom.toStringAsFixed(1)}x',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, const Offset(12, 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Classe para representar um marker no mapa
class MapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final Color color;
  final IconData icon;
  final String title;
  final dynamic data;

  const MapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.color,
    required this.icon,
    required this.title,
    this.data,
  });
}