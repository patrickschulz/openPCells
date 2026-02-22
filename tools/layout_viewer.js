class LayoutViewer {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext('2d');

        // View transform state
        this.pan = { x: 0, y: 0 };
        this.zoom = 1.0;
        this.baseZoom = 1.0; // Zoom level when layout fits in view (100%)
        this.zoomGain = 1.08; // Zoom factor per wheel step (adjustable)
        this.maxZoom = 20; // Maximum zoom level (ensures grid spacing stays >= 5 pixels)

        // Pan state
        this.isPanning = false;
        this.lastMousePos = { x: 0, y: 0 };

        // Layer palette drag state
        this.isDraggingLayers = false;
        this.dragMode = null; // 'enable' or 'disable'
        this.dragStarted = false; // Track if drag actually started (moved)

        // Ruler dimensions
        this.rulerSize = 30;

        // Palette width
        this.paletteWidth = 250;

        // Status bar height
        this.statusBarHeight = 30;

        // Background color
        this.backgroundColor = 'black';

        // Grid visibility
        this.gridVisible = true;

        // Rulers visibility
        this.rulersVisible = true;

        // Axes visibility
        this.axesVisible = true;

        // Sidebar collapsed state
        this.sidebarCollapsed = false;

        // Patterns enabled/disabled
        this.patternsEnabled = true;

        // Global opacity for all layers (used when patterns disabled)
        this.globalOpacity = 0.5;

        // Multi-pass rendering for better anti-aliasing
        this.renderPasses = 1;

        // Default font size for text shapes without explicit fontSize
        this.defaultFontSize = 500;

        // Text outline ratio (stroke width as percentage of font size)
        this.textOutlineRatio = 0.08;

        // Enabled shape types
        this.enabledShapeTypes = {
            'rect': true,
            'path': true,
            'polygon': true,
            'text': true
        };

        // Device pixel ratio for crisp rendering on high DPI displays
        this.dpr = window.devicePixelRatio || 1;

        // Layer configuration (colors, patterns, transparency, and line width for each layer)
        this.layerConfig = {
            'active': { color: '#00ff00', pattern: 'ddots', alpha: 1.0, lineWidth: 1 },
            'gate': { color: '#ff0000', pattern: 'ddots2', alpha: 1.0, lineWidth: 1 },
            'nimplant': { color: 'yellow', pattern: 'solid', alpha: 1.0, outlineOnly: true, lineWidth: 3 },
            'pimplant': { color: 'cyan', pattern: 'solid', alpha: 1.0, outlineOnly: true, lineWidth: 3 },
            'contactsourcedrain': { color: '#dddddd', pattern: 'fullcross', alpha: 1.0, lineWidth: 2 },
            'contactgate': { color: '#dddddd', pattern: 'fullcross', alpha: 1.0, lineWidth: 2 },
            'contactactive': { color: '#dddddd', pattern: 'fullcross', alpha: 1.0, lineWidth: 2 },
            'M1': { color: 'blue', pattern: 'diagonal-ne', alpha: 1.0, lineWidth: 2 },
            'viacutM1M2': { color: 'yellow', pattern: 'dots', alpha: 1.0, lineWidth: 1 },
            'M2': { color: 'hotpink', pattern: 'diagonal-nw', alpha: 1.0, lineWidth: 2 },
            'viacutM2M3': { color: 'magenta', pattern: 'dots', alpha: 1.0, lineWidth: 1 },
            'M3': { color: 'orange', pattern: 'vertical', alpha: 1.0, lineWidth: 2 },
            'text': { color: '#ffffff', pattern: 'solid', alpha: 1.0, lineWidth: 1 },
        };

        // Load shapes from external data file (with fallback to empty array)
        this.shapes = (typeof SHAPES_DATA !== 'undefined') ? SHAPES_DATA : [];

        // Selected file for load/reload functionality
        this.selectedFile = null;

        // Auto-generate layers from shapes
        this.layers = this.collectLayers();

        // Set canvas size to window size (after rectangles are initialized)
        // Canvas width excludes the palette
        this.setCanvasSize(window.innerWidth - this.paletteWidth, window.innerHeight);
        window.addEventListener('resize', () => this.resizeCanvas());

        // Initialize view to center on content
        this.centerView();

        // Setup event listeners
        this.setupEventListeners();

        // Create layer palette UI
        this.createLayerPalette();

        // Setup layer control buttons
        this.setupLayerControls();

        // Setup background toggle
        this.setupBackgroundToggle();

        // Setup tabs
        this.setupTabs();

        // Setup zoom gain control
        this.setupZoomGainControl();

        // Setup render passes control
        this.setupRenderPassesControl();

        // Setup default font size control
        this.setupDefaultFontSizeControl();

        // Setup text outline ratio control
        this.setupTextOutlineRatioControl();

        // Setup object type controls
        this.setupObjectTypeControls();

        // Setup reload data button
        this.setupReloadDataButton();

        // Setup sidebar toggle
        this.setupSidebarToggle();

        // Initial render
        this.render();
    }

    createPattern(color, patternType) {
        const size = 20; // Pattern tile size
        const canvas = document.createElement('canvas');
        canvas.width = size;
        canvas.height = size;
        const ctx = canvas.getContext('2d');

        // Fill with transparent background
        ctx.fillStyle = 'transparent';
        ctx.fillRect(0, 0, size, size);

        // Draw pattern
        ctx.strokeStyle = color;
        ctx.fillStyle = color;
        ctx.lineWidth = 1.5;

        switch (patternType) {
            case 'diagonal-ne': // Northeast diagonal lines
                ctx.beginPath();
                for (let i = -size; i < size; i += size / 2) {
                    ctx.moveTo(i, size);
                    ctx.lineTo(i + size, 0);
                }
                ctx.stroke();
                break;

            case 'diagonal-nw': // Northwest diagonal lines
                ctx.beginPath();
                for (let i = -size; i < size; i += size / 2) {
                    ctx.moveTo(i, 0);
                    ctx.lineTo(i + size, size);
                }
                ctx.stroke();
                break;

            case 'horizontal': // Horizontal lines
                ctx.beginPath();
                for (let y = 0; y < size; y += 4) {
                    ctx.moveTo(0, y);
                    ctx.lineTo(size, y);
                }
                ctx.stroke();
                break;

            case 'vertical': // Vertical lines
                ctx.beginPath();
                for (let x = 0; x < size; x += 4) {
                    ctx.moveTo(x, 0);
                    ctx.lineTo(x, size);
                }
                ctx.stroke();
                break;

            case 'checkerboard': // Checkerboard pattern
                const squareSize = size / 4;
                for (let y = 0; y < 4; y++) {
                    for (let x = 0; x < 4; x++) {
                        if ((x + y) % 2 === 0) {
                            ctx.fillRect(x * squareSize, y * squareSize, squareSize, squareSize);
                        }
                    }
                }
                break;

            case 'ddots': // Diagonal/staggered dots
                const ddotRadius = 2.0;
                const ddotspacing = 10;
                let rowIndex = 0;
                for (let y = ddotspacing / 2; y < size; y += ddotspacing) {
                    // Alternate between two starting positions for brick pattern
                    const xStart = (rowIndex % 2) ? 0 : ddotspacing / 2;
                    for (let x = xStart; x <= size; x += ddotspacing) {
                        ctx.beginPath();
                        ctx.arc(x, y, ddotRadius, 0, Math.PI * 2);
                        ctx.fill();
                    }
                    rowIndex++;
                }
                break;

            case 'ddots2': // Diagonal/staggered dots (shifted in x and y)
                const ddot2Radius = 2.0;
                const ddot2spacing = 10;
                let row2Index = 0;
                // Start at 0 instead of spacing/2 to shift vertically by half
                for (let y = 0; y <= size; y += ddot2spacing) {
                    // Alternate between two starting positions (opposite of ddots)
                    const xStart = (row2Index % 2) ? ddot2spacing / 2 : 0;
                    for (let x = xStart; x <= size; x += ddot2spacing) {
                        ctx.beginPath();
                        ctx.arc(x, y, ddot2Radius, 0, Math.PI * 2);
                        ctx.fill();
                    }
                    row2Index++;
                }
                break;

            case 'dots': // Polka dots
                const dotRadius = 1.5;
                const spacing = 10;
                for (let y = spacing / 2; y < size; y += spacing) {
                    for (let x = spacing / 2; x < size; x += spacing) {
                        ctx.beginPath();
                        ctx.arc(x, y, dotRadius, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }
                break;

            case 'cross': // Cross-hatch pattern
                ctx.beginPath();
                for (let i = -size; i < size * 2; i += 4) {
                    ctx.moveTo(i, 0);
                    ctx.lineTo(i + size, size);
                    ctx.moveTo(i, size);
                    ctx.lineTo(i + size, 0);
                }
                ctx.stroke();
                break;

            case 'fullcross': // Cross-hatch pattern
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(size, size);
                ctx.moveTo(0, size);
                ctx.lineTo(size, 0);
                ctx.stroke();
                break;

            case 'solid': // Solid fill
            default:
                ctx.fillStyle = color;
                ctx.fillRect(0, 0, size, size);
                break;
        }

        return this.ctx.createPattern(canvas, 'repeat');
    }

    collectLayers() {
        // Find all unique layer names from shapes
        const layerNames = new Set();
        this.shapes.forEach(shape => {
            if (shape.layer) {
                layerNames.add(shape.layer);
            }
        });

        // Convert to array and sort based on layerConfig order
        const layerNamesArray = Array.from(layerNames);
        const configKeys = Object.keys(this.layerConfig);

        layerNamesArray.sort((a, b) => {
            const indexA = configKeys.indexOf(a);
            const indexB = configKeys.indexOf(b);

            // If both are in config, sort by their order in config
            if (indexA !== -1 && indexB !== -1) {
                return indexA - indexB;
            }
            // If only a is in config, a comes first
            if (indexA !== -1) return -1;
            // If only b is in config, b comes first
            if (indexB !== -1) return 1;
            // If neither is in config, maintain original order (or alphabetical)
            return a.localeCompare(b);
        });

        // Create layer objects from config in sorted order
        const layers = [];
        layerNamesArray.forEach(name => {
            const config = this.layerConfig[name] || { color: 'gray', pattern: 'solid', alpha: 1.0, outlineOnly: false, lineWidth: 1 };
            const pattern = this.createPattern(config.color, config.pattern || 'solid');
            layers.push({
                name: name,
                color: config.color,
                pattern: pattern,
                patternType: config.pattern || 'solid',
                alpha: config.alpha !== undefined ? config.alpha : 1.0,
                outlineOnly: config.outlineOnly || false,
                lineWidth: config.lineWidth !== undefined ? config.lineWidth : 1,
                visible: true
            });
        });

        return layers;
    }

    setCanvasSize(width, height) {
        // Store logical dimensions
        this.canvasWidth = width;
        this.canvasHeight = height;

        // Set CSS size (logical pixels)
        this.canvas.style.width = width + 'px';
        this.canvas.style.height = height + 'px';

        // Set actual canvas buffer size (scaled by device pixel ratio for crisp rendering)
        this.canvas.width = width * this.dpr;
        this.canvas.height = height * this.dpr;

        // Reset transform and scale the context to match device pixel ratio
        this.ctx.setTransform(1, 0, 0, 1, 0, 0);
        this.ctx.scale(this.dpr, this.dpr);
    }

    resizeCanvas() {
        // Canvas width excludes the palette (unless sidebar is collapsed)
        const paletteSpace = this.sidebarCollapsed ? 0 : this.paletteWidth;
        const width = window.innerWidth - paletteSpace;
        // Canvas height excludes the status bar
        const height = window.innerHeight - this.statusBarHeight;
        this.setCanvasSize(width, height);
        this.centerView();
        this.render();
    }

    centerView() {
        // Calculate bounding box of all shapes
        let minX = Infinity, minY = Infinity;
        let maxX = -Infinity, maxY = -Infinity;
        let hasShapes = false;

        this.shapes.forEach(shape => {
            hasShapes = true;

            if (shape.type === 'rect') {
                minX = Math.min(minX, shape.x);
                minY = Math.min(minY, shape.y);
                maxX = Math.max(maxX, shape.x + shape.width);
                maxY = Math.max(maxY, shape.y + shape.height);
            } else if (shape.type === 'path' || shape.type === 'polygon') {
                shape.points.forEach(point => {
                    minX = Math.min(minX, point.x);
                    minY = Math.min(minY, point.y);
                    maxX = Math.max(maxX, point.x);
                    maxY = Math.max(maxY, point.y);
                });
                // Account for path width
                if (shape.type === 'path' && shape.width) {
                    const halfWidth = shape.width / 2;
                    minX -= halfWidth;
                    minY -= halfWidth;
                    maxX += halfWidth;
                    maxY += halfWidth;
                }
            } else if (shape.type === 'text') {
                // Approximate text bounds (will be more accurate after measuring)
                const fontSize = shape.fontSize || this.defaultFontSize;
                const approxWidth = (shape.text.length * fontSize) * 0.6;
                const approxHeight = fontSize;
                minX = Math.min(minX, shape.x - approxWidth / 2);
                minY = Math.min(minY, shape.y - approxHeight / 2);
                maxX = Math.max(maxX, shape.x + approxWidth / 2);
                maxY = Math.max(maxY, shape.y + approxHeight / 2);
            }
        });

        if (!hasShapes) return;

        const contentWidth = maxX - minX;
        const contentHeight = maxY - minY;
        const contentCenterX = minX + contentWidth / 2;
        const contentCenterY = minY + contentHeight / 2;

        // Center the content in the canvas with some padding
        // Account for ruler space
        const padding = 50;
        const availableWidth = this.canvasWidth - this.rulerSize - 2 * padding;
        const availableHeight = this.canvasHeight - this.rulerSize - 2 * padding;
        const zoomX = availableWidth / contentWidth;
        const zoomY = availableHeight / contentHeight;
        this.setZoom(Math.min(zoomX, zoomY));

        // Store this as the base zoom (100% = fit all content)
        this.baseZoom = this.zoom;

        this.pan.x = (this.canvasWidth + this.rulerSize) / 2 - contentCenterX * this.zoom;
        this.pan.y = (this.canvasHeight + this.rulerSize) / 2 - contentCenterY * this.zoom;
    }

    setupEventListeners() {
        // Mouse wheel for zoom/pan
        this.canvas.addEventListener('wheel', (e) => {
            e.preventDefault();

            if (e.shiftKey) {
                // Shift + wheel: Pan horizontally
                const panSpeed = 2;
                this.pan.x -= e.deltaY * panSpeed;
                this.render();
            } else if (e.ctrlKey || e.metaKey) {
                // Ctrl + wheel: Pan vertically
                const panSpeed = 2;
                this.pan.y -= e.deltaY * panSpeed;
                this.render();
            } else {
                // No modifier: Zoom
                const rect = this.canvas.getBoundingClientRect();
                const mouseX = e.clientX - rect.left;
                const mouseY = e.clientY - rect.top;

                // Get world coordinates before zoom
                const worldX = (mouseX - this.pan.x) / this.zoom;
                const worldY = (mouseY - this.pan.y) / this.zoom;

                // Update zoom
                const zoomFactor = e.deltaY > 0 ? (1 / this.zoomGain) : this.zoomGain;
                this.setZoom(this.zoom * zoomFactor);

                // Adjust pan to keep mouse position fixed
                this.pan.x = mouseX - worldX * this.zoom;
                this.pan.y = mouseY - worldY * this.zoom;

                this.updateZoomDisplay();
                this.render();
            }
        });

        // Mouse down - start panning
        this.canvas.addEventListener('mousedown', (e) => {
            this.isPanning = true;
            this.lastMousePos = { x: e.clientX, y: e.clientY };
        });

        // Mouse move - pan if dragging
        this.canvas.addEventListener('mousemove', (e) => {
            if (this.isPanning) {
                let dx = e.clientX - this.lastMousePos.x;
                let dy = e.clientY - this.lastMousePos.y;

                // Restrict panning based on modifier keys
                if (e.shiftKey) {
                    // Shift: horizontal-only panning
                    dy = 0;
                } else if (e.ctrlKey || e.metaKey) {
                    // Ctrl: vertical-only panning
                    dx = 0;
                }

                this.pan.x += dx;
                this.pan.y += dy;

                this.lastMousePos = { x: e.clientX, y: e.clientY };
                this.render();
            }
        });

        // Mouse up - stop panning
        this.canvas.addEventListener('mouseup', () => {
            this.isPanning = false;
        });

        // Mouse leave - stop panning
        this.canvas.addEventListener('mouseleave', () => {
            this.isPanning = false;
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'f' || e.key === 'F') {
                // F key: Fit/center view
                this.centerView();
                this.updateZoomDisplay();
                this.render();
            } else if (e.key.startsWith('Arrow')) {
                // Arrow keys: Pan the canvas
                e.preventDefault(); // Prevent page scrolling
                const panSpeed = 50; // Pixels to pan per key press

                switch(e.key) {
                    case 'ArrowUp':
                        this.pan.y += panSpeed;
                        break;
                    case 'ArrowDown':
                        this.pan.y -= panSpeed;
                        break;
                    case 'ArrowLeft':
                        this.pan.x += panSpeed;
                        break;
                    case 'ArrowRight':
                        this.pan.x -= panSpeed;
                        break;
                }
                this.render();
            }
        });

        // Track mouse position for status bar
        this.canvas.addEventListener('mousemove', (e) => {
            const rect = this.canvas.getBoundingClientRect();
            const mouseX = e.clientX - rect.left;
            const mouseY = e.clientY - rect.top;

            // Convert to world coordinates
            const worldX = (mouseX - this.pan.x) / this.zoom;
            const worldY = (mouseY - this.pan.y) / this.zoom;

            // Update status bar
            document.getElementById('cursor-x').textContent = `X: ${Math.round(worldX)}`;
            document.getElementById('cursor-y').textContent = `Y: ${Math.round(worldY)}`;
        });
    }

    updateZoomDisplay() {
        // Display zoom relative to base zoom (fit-all = 100%)
        const zoomPercent = Math.round((this.zoom / this.baseZoom) * 100);
        document.getElementById('zoom-level').textContent = `Zoom: ${zoomPercent}%`;
    }

    setZoom(newZoom) {
        // Clamp zoom to maximum to keep grid spacing >= 5 pixels
        this.zoom = Math.min(newZoom, this.maxZoom);
    }

    getGridSpacing() {
        // Calculate appropriate grid spacing based on zoom level
        // Target: grid lines every 50-100 pixels on screen
        const targetPixelSpacing = 80;
        const worldSpacing = targetPixelSpacing / this.zoom;

        // Round to nice numbers (1, 2, 5, 10, 20, 50, 100, etc.)
        const magnitude = Math.pow(10, Math.floor(Math.log10(worldSpacing)));
        const normalized = worldSpacing / magnitude;

        let niceSpacing;
        if (normalized < 1.5) {
            niceSpacing = 1;
        } else if (normalized < 3.5) {
            niceSpacing = 2;
        } else if (normalized < 7.5) {
            niceSpacing = 5;
        } else {
            niceSpacing = 10;
        }

        return niceSpacing * magnitude;
    }

    drawGrid() {
        const spacing = this.getGridSpacing();
        const minorSpacing = spacing / 5;

        // Calculate visible world bounds
        const minWorldX = -this.pan.x / this.zoom;
        const maxWorldX = (this.canvasWidth - this.pan.x) / this.zoom;
        const minWorldY = -this.pan.y / this.zoom;
        const maxWorldY = (this.canvasHeight - this.pan.y) / this.zoom;

        // Adjust grid colors based on background
        const isBlackBg = this.backgroundColor === 'black';
        const minorGridColor = isBlackBg ? 'rgba(80, 80, 80, 0.5)' : 'rgba(200, 200, 200, 0.5)';
        const majorGridColor = isBlackBg ? 'rgba(120, 120, 120, 0.8)' : 'rgba(150, 150, 150, 0.8)';

        // Draw minor grid lines
        this.ctx.strokeStyle = minorGridColor;
        this.ctx.lineWidth = 1 / this.zoom;
        this.ctx.beginPath();

        // Vertical minor lines
        const startMinorX = Math.floor(minWorldX / minorSpacing) * minorSpacing;
        for (let x = startMinorX; x <= maxWorldX; x += minorSpacing) {
            if (Math.abs(x % spacing) < 0.001) continue; // Skip major lines
            this.ctx.moveTo(x, minWorldY);
            this.ctx.lineTo(x, maxWorldY);
        }

        // Horizontal minor lines
        const startMinorY = Math.floor(minWorldY / minorSpacing) * minorSpacing;
        for (let y = startMinorY; y <= maxWorldY; y += minorSpacing) {
            if (Math.abs(y % spacing) < 0.001) continue; // Skip major lines
            this.ctx.moveTo(minWorldX, y);
            this.ctx.lineTo(maxWorldX, y);
        }

        this.ctx.stroke();

        // Draw major grid lines
        this.ctx.strokeStyle = majorGridColor;
        this.ctx.lineWidth = 1.5 / this.zoom;
        this.ctx.beginPath();

        // Vertical major lines
        const startX = Math.floor(minWorldX / spacing) * spacing;
        for (let x = startX; x <= maxWorldX; x += spacing) {
            this.ctx.moveTo(x, minWorldY);
            this.ctx.lineTo(x, maxWorldY);
        }

        // Horizontal major lines
        const startY = Math.floor(minWorldY / spacing) * spacing;
        for (let y = startY; y <= maxWorldY; y += spacing) {
            this.ctx.moveTo(minWorldX, y);
            this.ctx.lineTo(maxWorldX, y);
        }

        this.ctx.stroke();
    }

    drawAxes() {
        // Calculate visible world bounds
        const minWorldX = -this.pan.x / this.zoom;
        const maxWorldX = (this.canvasWidth - this.pan.x) / this.zoom;
        const minWorldY = -this.pan.y / this.zoom;
        const maxWorldY = (this.canvasHeight - this.pan.y) / this.zoom;

        // Adjust axes color based on background
        const isBlackBg = this.backgroundColor === 'black';
        const axesColor = isBlackBg ? 'rgba(255, 255, 255, 0.8)' : 'rgba(0, 0, 0, 0.8)';

        this.ctx.save();
        this.ctx.strokeStyle = axesColor;
        this.ctx.lineWidth = 2 / this.zoom;
        this.ctx.beginPath();

        // Draw X-axis (horizontal line at y=0)
        if (minWorldY <= 0 && maxWorldY >= 0) {
            this.ctx.moveTo(minWorldX, 0);
            this.ctx.lineTo(maxWorldX, 0);
        }

        // Draw Y-axis (vertical line at x=0)
        if (minWorldX <= 0 && maxWorldX >= 0) {
            this.ctx.moveTo(0, minWorldY);
            this.ctx.lineTo(0, maxWorldY);
        }

        this.ctx.stroke();
        this.ctx.restore();
    }

    drawRulers() {
        const spacing = this.getGridSpacing();

        // Calculate visible world bounds
        const minWorldX = -this.pan.x / this.zoom;
        const maxWorldX = (this.canvasWidth - this.pan.x) / this.zoom;
        const minWorldY = -this.pan.y / this.zoom;
        const maxWorldY = (this.canvasHeight - this.pan.y) / this.zoom;

        // Adjust ruler colors based on background
        const isBlackBg = this.backgroundColor === 'black';
        const rulerBgColor = isBlackBg ? 'rgba(30, 30, 30, 0.95)' : 'rgba(240, 240, 240, 0.95)';
        const rulerBorderColor = isBlackBg ? 'rgba(150, 150, 150, 0.8)' : 'rgba(100, 100, 100, 0.8)';
        const rulerTextColor = isBlackBg ? 'white' : 'black';

        // Draw ruler backgrounds
        this.ctx.fillStyle = rulerBgColor;
        this.ctx.fillRect(-this.pan.x / this.zoom, -this.pan.y / this.zoom,
                         (this.canvasWidth) / this.zoom, this.rulerSize / this.zoom);
        this.ctx.fillRect(-this.pan.x / this.zoom, -this.pan.y / this.zoom,
                         this.rulerSize / this.zoom, (this.canvasHeight) / this.zoom);

        // Draw ruler borders
        this.ctx.strokeStyle = rulerBorderColor;
        this.ctx.lineWidth = 1 / this.zoom;
        this.ctx.strokeRect(-this.pan.x / this.zoom, -this.pan.y / this.zoom,
                           (this.canvasWidth) / this.zoom, this.rulerSize / this.zoom);
        this.ctx.strokeRect(-this.pan.x / this.zoom, -this.pan.y / this.zoom,
                           this.rulerSize / this.zoom, (this.canvasHeight) / this.zoom);

        // Setup text
        this.ctx.fillStyle = rulerTextColor;
        this.ctx.font = `${12 / this.zoom}px Arial`;
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';

        // Horizontal ruler (top)
        const startX = Math.floor(minWorldX / spacing) * spacing;
        for (let x = startX; x <= maxWorldX; x += spacing) {
            const screenX = x;
            const rulerY = -this.pan.y / this.zoom;

            // Draw tick
            this.ctx.beginPath();
            this.ctx.moveTo(screenX, rulerY + this.rulerSize / this.zoom);
            this.ctx.lineTo(screenX, rulerY + this.rulerSize * 0.7 / this.zoom);
            this.ctx.stroke();

            // Draw label
            this.ctx.fillText(x.toString(), screenX, rulerY + this.rulerSize * 0.35 / this.zoom);
        }

        // Vertical ruler (left)
        this.ctx.textAlign = 'center';
        const startY = Math.floor(minWorldY / spacing) * spacing;
        for (let y = startY; y <= maxWorldY; y += spacing) {
            const screenY = y;
            const rulerX = -this.pan.x / this.zoom;

            // Draw tick
            this.ctx.beginPath();
            this.ctx.moveTo(rulerX + this.rulerSize / this.zoom, screenY);
            this.ctx.lineTo(rulerX + this.rulerSize * 0.7 / this.zoom, screenY);
            this.ctx.stroke();

            // Draw label
            this.ctx.save();
            this.ctx.translate(rulerX + this.rulerSize * 0.35 / this.zoom, screenY);
            this.ctx.rotate(-Math.PI / 2);
            this.ctx.fillText(y.toString(), 0, 0);
            this.ctx.restore();
        }
    }

    createLayerPalette() {
        const layerList = document.getElementById('layer-list');
        layerList.innerHTML = '';

        this.layers.forEach((layer, index) => {
            const layerItem = document.createElement('div');
            layerItem.className = 'layer-item';

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.className = 'layer-checkbox';
            checkbox.checked = layer.visible;
            checkbox.addEventListener('change', () => this.toggleLayer(index));

            const colorBox = document.createElement('canvas');
            colorBox.className = 'layer-color';
            colorBox.width = 20;
            colorBox.height = 20;
            const boxCtx = colorBox.getContext('2d');

            // Draw pattern preview
            if (this.patternsEnabled) {
                const previewPattern = this.createPattern(layer.color, layer.patternType);
                boxCtx.fillStyle = previewPattern;
                boxCtx.fillRect(0, 0, 20, 20);
            } else {
                boxCtx.fillStyle = layer.color;
                boxCtx.fillRect(0, 0, 20, 20);
            }
            boxCtx.strokeStyle = '#999';
            boxCtx.lineWidth = 1;
            boxCtx.strokeRect(0, 0, 20, 20);

            const nameLabel = document.createElement('span');
            nameLabel.className = 'layer-name';
            nameLabel.textContent = layer.name;

            layerItem.appendChild(checkbox);
            layerItem.appendChild(colorBox);
            layerItem.appendChild(nameLabel);

            // Click on layer item also toggles checkbox
            // Shift-click solos the layer (turns off all others)
            // Only process click if it wasn't a drag operation
            layerItem.addEventListener('click', (e) => {
                if (e.target !== checkbox && !this.dragStarted) {
                    if (e.shiftKey) {
                        // Solo mode: turn off all layers except this one
                        this.soloLayer(index);
                    } else {
                        checkbox.checked = !checkbox.checked;
                        this.toggleLayer(index);
                    }
                }
            });

            // Drag-to-enable/disable: mousedown prepares for dragging
            // Normal drag: enable layers
            // Ctrl+drag: disable layers
            layerItem.addEventListener('mousedown', (e) => {
                if (e.target !== checkbox && !e.shiftKey) {
                    this.isDraggingLayers = true;
                    this.dragStarted = false; // Not started until we enter another layer
                    if (e.ctrlKey || e.metaKey) {
                        // Ctrl/Cmd+drag disables layers
                        this.dragMode = 'disable';
                    } else {
                        // Normal drag enables layers
                        this.dragMode = 'enable';
                    }
                    e.preventDefault(); // Prevent text selection during drag
                }
            });

            // Drag-to-enable/disable: mouseenter enables or disables layer based on drag mode
            layerItem.addEventListener('mouseenter', () => {
                if (this.isDraggingLayers) {
                    this.dragStarted = true; // Mark that drag has actually started
                    if (this.dragMode === 'disable') {
                        this.disableLayer(index);
                    } else {
                        this.enableLayer(index);
                    }
                }
            });

            layerList.appendChild(layerItem);
        });

        // Global mouseup to end drag-to-enable/disable
        document.addEventListener('mouseup', () => {
            this.isDraggingLayers = false;
            this.dragMode = null;
            this.dragStarted = false;
        });
    }

    setupLayerControls() {
        const enableAllBtn = document.getElementById('enable-all-btn');
        const disableAllBtn = document.getElementById('disable-all-btn');
        const feolBtn = document.getElementById('feol-btn');
        const beolBtn = document.getElementById('beol-btn');

        enableAllBtn.addEventListener('click', () => {
            this.enableAllLayers();
        });

        disableAllBtn.addEventListener('click', () => {
            this.disableAllLayers();
        });

        feolBtn.addEventListener('click', () => {
            this.showFEOLLayers();
        });

        beolBtn.addEventListener('click', () => {
            this.showBEOLLayers();
        });

        const togglePatternsBtn = document.getElementById('toggle-patterns-btn');
        const globalOpacitySlider = document.getElementById('global-opacity-slider');
        const globalOpacityLabel = document.getElementById('global-opacity-label');

        // Initialize opacity slider
        globalOpacitySlider.value = this.globalOpacity;

        // Initially disable slider and grey out label since patterns are enabled by default
        globalOpacitySlider.disabled = this.patternsEnabled;
        globalOpacityLabel.style.color = this.patternsEnabled ? '#999' : '#000';

        togglePatternsBtn.addEventListener('click', () => {
            this.patternsEnabled = !this.patternsEnabled;
            togglePatternsBtn.textContent = this.patternsEnabled ? 'Patterns: On' : 'Patterns: Off';
            globalOpacitySlider.disabled = this.patternsEnabled;
            globalOpacityLabel.style.color = this.patternsEnabled ? '#999' : '#000';
            this.createLayerPalette();
            this.render();
        });

        globalOpacitySlider.addEventListener('input', () => {
            this.globalOpacity = parseFloat(globalOpacitySlider.value);
            this.render();
        });
    }

    enableAllLayers() {
        this.layers.forEach((layer) => {
            layer.visible = true;
        });
        // Update all checkboxes
        const checkboxes = document.querySelectorAll('.layer-checkbox');
        checkboxes.forEach((checkbox) => {
            checkbox.checked = true;
        });
        this.render();
    }

    disableAllLayers() {
        this.layers.forEach((layer) => {
            layer.visible = false;
        });
        // Update all checkboxes
        const checkboxes = document.querySelectorAll('.layer-checkbox');
        checkboxes.forEach((checkbox) => {
            checkbox.checked = false;
        });
        this.render();
    }

    showFEOLLayers() {
        // FEOL (Front End Of Line): active, gate, nimplant, contactsourcedrain, contactgate
        const feolLayers = ['active', 'gate', 'nimplant', 'pimplant', 'contactsourcedrain', 'contactgate', 'contactactive'];
        this.layers.forEach((layer) => {
            layer.visible = feolLayers.includes(layer.name);
        });
        // Update all checkboxes
        const checkboxes = document.querySelectorAll('.layer-checkbox');
        checkboxes.forEach((checkbox, i) => {
            checkbox.checked = this.layers[i].visible;
        });
        this.render();
    }

    showBEOLLayers() {
        // BEOL (Back End Of Line): M1, viacutM1M2, M2, viacutM2M3, M3
        const beolLayers = ['M1', 'viacutM1M2', 'M2', 'viacutM2M3', 'M3'];
        this.layers.forEach((layer) => {
            layer.visible = beolLayers.includes(layer.name);
        });
        // Update all checkboxes
        const checkboxes = document.querySelectorAll('.layer-checkbox');
        checkboxes.forEach((checkbox, i) => {
            checkbox.checked = this.layers[i].visible;
        });
        this.render();
    }

    toggleLayer(index) {
        this.layers[index].visible = !this.layers[index].visible;
        this.render();
    }

    soloLayer(index) {
        // Turn off all layers except the one at index
        this.layers.forEach((layer, i) => {
            layer.visible = (i === index);
        });
        // Update all checkboxes
        const checkboxes = document.querySelectorAll('.layer-checkbox');
        checkboxes.forEach((checkbox, i) => {
            checkbox.checked = this.layers[i].visible;
        });
        this.render();
    }

    enableLayer(index) {
        // Enable a layer if it's not already enabled
        if (!this.layers[index].visible) {
            this.layers[index].visible = true;
            const checkboxes = document.querySelectorAll('.layer-checkbox');
            checkboxes[index].checked = true;
            this.render();
        }
    }

    disableLayer(index) {
        // Disable a layer if it's not already disabled
        if (this.layers[index].visible) {
            this.layers[index].visible = false;
            const checkboxes = document.querySelectorAll('.layer-checkbox');
            checkboxes[index].checked = false;
            this.render();
        }
    }

    setupTabs() {
        const tabBtns = document.querySelectorAll('.tab-btn');
        tabBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const tabName = btn.dataset.tab;

                // Remove active class from all tabs and buttons
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));

                // Add active class to clicked button and corresponding tab
                btn.classList.add('active');
                document.getElementById(`${tabName}-tab`).classList.add('active');
            });
        });
    }

    setupZoomGainControl() {
        const slider = document.getElementById('zoom-gain-slider');
        const valueDisplay = document.getElementById('zoom-gain-value');

        // Initialize slider position based on current zoomGain
        slider.value = (this.zoomGain - 1.0) * 100;

        // Update zoom gain when slider changes
        slider.addEventListener('input', () => {
            // Map slider value (4-12) to zoom gain (1.04-1.12)
            this.zoomGain = 1.0 + (slider.value / 100);
            valueDisplay.textContent = this.zoomGain.toFixed(2) + 'x';
        });

        // Initialize display
        valueDisplay.textContent = this.zoomGain.toFixed(2) + 'x';
    }

    setupRenderPassesControl() {
        const slider = document.getElementById('render-passes-slider');
        const valueDisplay = document.getElementById('render-passes-value');

        // Initialize slider position based on current renderPasses
        slider.value = this.renderPasses;

        // Update render passes when slider changes
        slider.addEventListener('input', () => {
            this.renderPasses = parseInt(slider.value);
            valueDisplay.textContent = this.renderPasses;
            this.render(); // Re-render with new passes
        });

        // Initialize display
        valueDisplay.textContent = this.renderPasses;
    }

    setupDefaultFontSizeControl() {
        const input = document.getElementById('default-font-size');

        // Initialize input value based on current defaultFontSize
        input.value = this.defaultFontSize;

        // Update default font size when input changes
        input.addEventListener('input', () => {
            this.defaultFontSize = parseInt(input.value) || 500;
            this.centerView(); // Recalculate bounds with new font size
            this.render(); // Re-render with new font size
        });
    }

    setupTextOutlineRatioControl() {
        const input = document.getElementById('text-outline-ratio');

        // Initialize input value based on current textOutlineRatio
        input.value = this.textOutlineRatio;

        // Update text outline ratio when input changes
        input.addEventListener('input', () => {
            this.textOutlineRatio = parseFloat(input.value) || 0.08;
            this.render(); // Re-render with new outline ratio
        });
    }

    setupObjectTypeControls() {
        const shapeTypes = ['rect', 'path', 'polygon', 'text'];

        shapeTypes.forEach(type => {
            const checkbox = document.getElementById(`object-${type}`);
            if (checkbox) {
                // Initialize checkbox state
                checkbox.checked = this.enabledShapeTypes[type];

                // Update enabled shape types when checkbox changes
                checkbox.addEventListener('change', () => {
                    this.enabledShapeTypes[type] = checkbox.checked;
                    this.render(); // Re-render with updated shape types
                });

                // Make entire object item clickable
                const objectItem = checkbox.closest('.object-item');
                const label = objectItem.querySelector('label');
                if (objectItem) {
                    objectItem.addEventListener('click', (e) => {
                        // Don't toggle if clicking the checkbox itself (it toggles naturally)
                        // Don't toggle if clicking the label (it triggers the checkbox via 'for' attribute)
                        if (e.target !== checkbox && e.target !== label) {
                            checkbox.click(); // Use click() to trigger the change event properly
                        }
                    });
                }
            }
        });
    }

    setupReloadDataButton() {
        const fileInput = document.getElementById('layout-file-input');
        const reloadBtn = document.getElementById('reload-data-btn');

        // Load file when selected
        if (fileInput) {
            fileInput.addEventListener('change', (e) => {
                if (e.target.files[0]) {
                    this.selectedFile = e.target.files[0];
                    this.loadLayoutDataFromFile(this.selectedFile);
                }
            });
        }

        // Reload button - reload the file, keeping previous data if read fails
        if (reloadBtn) {
            reloadBtn.addEventListener('click', () => {
                if (this.selectedFile) {
                    // Pass true to keepDataOnError so we don't lose data if reload fails
                    this.loadLayoutDataFromFile(this.selectedFile, true);
                }
            });
            // Disabled for now due to browser FileReader limitations
            reloadBtn.disabled = true;
        }
    }

    loadLayoutDataFromFile(file, keepDataOnError = false, retryCount = 0) {
        // Read the selected file
        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const data = JSON.parse(e.target.result);
                if (!Array.isArray(data)) {
                    throw new Error('JSON data is not an array');
                }
                this.shapes = data;
                this.reinitializeView();
                this.updateCurrentFileLabel(file.name);
                console.log('Layout data loaded successfully:', data.length, 'shapes');
            } catch (error) {
                console.error('Failed to parse JSON file:', error);
                alert('Failed to load file: ' + error.message);
                if (!keepDataOnError) {
                    this.shapes = [];
                    this.reinitializeView();
                }
            }
        };
        reader.onerror = (error) => {
            console.error('Failed to read file:', error);

            // Retry once after a short delay in case file is temporarily locked
            if (retryCount < 1) {
                console.log('Retrying file read after 500ms...');
                setTimeout(() => {
                    this.loadLayoutDataFromFile(file, keepDataOnError, retryCount + 1);
                }, 500);
                return;
            }

            alert('Failed to read file');
            if (!keepDataOnError) {
                this.shapes = [];
                this.reinitializeView();
            }
        };
        console.log('Reading file:', file.name);
        reader.readAsText(file);
    }

    updateCurrentFileLabel(fileName) {
        const fileLabel = document.getElementById('current-file-label');
        if (fileLabel) {
            fileLabel.textContent = fileName;
        }
    }

    reinitializeView() {
        // Reinitialize layers from new shapes data
        this.layers = this.collectLayers();
        this.createLayerPalette();
        this.centerView();
        this.render();
    }

    setupSidebarToggle() {
        const toggleBtn = document.getElementById('sidebar-toggle');
        const palette = document.getElementById('layer-palette');

        const toggleSidebar = () => {
            this.sidebarCollapsed = !this.sidebarCollapsed;

            if (this.sidebarCollapsed) {
                palette.classList.add('collapsed');
                toggleBtn.classList.add('collapsed');
                toggleBtn.textContent = '◀';
            } else {
                palette.classList.remove('collapsed');
                toggleBtn.classList.remove('collapsed');
                toggleBtn.textContent = '▶';
            }

            // Resize canvas to take advantage of space
            this.resizeCanvas();
        };

        // Toggle on button click
        toggleBtn.addEventListener('click', toggleSidebar);

        // Toggle on Tab key press
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Tab') {
                e.preventDefault(); // Prevent default tab navigation
                toggleSidebar();
            }
        });
    }

    setupBackgroundToggle() {
        const bgToggleBtn = document.getElementById('bg-toggle');

        // Initialize button to show current background
        bgToggleBtn.textContent = this.backgroundColor === 'white' ? 'White' : 'Black';

        bgToggleBtn.addEventListener('click', () => {
            if (this.backgroundColor === 'white') {
                this.backgroundColor = 'black';
                bgToggleBtn.textContent = 'Black';
            } else {
                this.backgroundColor = 'white';
                bgToggleBtn.textContent = 'White';
            }
            this.render();
        });

        const gridToggleBtn = document.getElementById('grid-toggle');
        gridToggleBtn.addEventListener('click', () => {
            this.gridVisible = !this.gridVisible;
            if (this.gridVisible) {
                gridToggleBtn.textContent = 'Visible';
            } else {
                gridToggleBtn.textContent = 'Hidden';
            }
            this.render();
        });

        const rulersToggleBtn = document.getElementById('rulers-toggle');
        rulersToggleBtn.addEventListener('click', () => {
            this.rulersVisible = !this.rulersVisible;
            if (this.rulersVisible) {
                rulersToggleBtn.textContent = 'Visible';
            } else {
                rulersToggleBtn.textContent = 'Hidden';
            }
            this.render();
        });

        const axesToggleBtn = document.getElementById('axes-toggle');
        axesToggleBtn.addEventListener('click', () => {
            this.axesVisible = !this.axesVisible;
            if (this.axesVisible) {
                axesToggleBtn.textContent = 'Visible';
            } else {
                axesToggleBtn.textContent = 'Hidden';
            }
            this.render();
        });
    }

    render() {
        // Clear canvas with background color
        this.ctx.fillStyle = this.backgroundColor;
        this.ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

        // Save context
        this.ctx.save();

        // Multi-pass rendering for anti-aliasing
        for (let pass = 0; pass < this.renderPasses; pass++) {
            // Calculate sub-pixel offset for this pass
            const offsetX = (pass % 2) * 0.5 / this.zoom;
            const offsetY = Math.floor(pass / 2) * 0.5 / this.zoom;

            this.ctx.save();

            // Apply transformations with sub-pixel offset
            this.ctx.translate(this.pan.x, this.pan.y);
            this.ctx.scale(this.zoom, this.zoom);
            this.ctx.translate(offsetX, offsetY);

            // Reduce opacity for multiple passes to blend them
            this.ctx.globalAlpha = 1.0 / this.renderPasses;

            // Draw grid (if enabled)
            if (this.gridVisible) {
                this.drawGrid();
            }

            // Draw axes (if enabled)
            if (this.axesVisible) {
                this.drawAxes();
            }

            // Draw shapes in layer order (not data order) to match palette rendering order
            this.layers.forEach(layer => {
                if (!layer.visible) return;

                // Find all shapes for this layer
                this.shapes.forEach(shape => {
                    if (shape.layer !== layer.name) return;

                    // Skip if this shape type is disabled
                    if (!this.enabledShapeTypes[shape.type]) return;

                    if (shape.type === 'rect') {
                        // Draw rectangle with pattern or solid color
                        if (!layer.outlineOnly) {
                            this.ctx.save();
                            this.ctx.globalAlpha = this.patternsEnabled ? layer.alpha : layer.alpha * this.globalOpacity;

                            if (this.patternsEnabled) {
                                // Draw with pattern
                                this.ctx.scale(1 / this.zoom, 1 / this.zoom);
                                this.ctx.fillStyle = layer.pattern;
                                this.ctx.fillRect(shape.x * this.zoom, shape.y * this.zoom,
                                    shape.width * this.zoom, shape.height * this.zoom);
                            } else {
                                // Draw with solid color
                                this.ctx.fillStyle = layer.color;
                                this.ctx.fillRect(shape.x, shape.y, shape.width, shape.height);
                            }
                            this.ctx.restore();
                        }

                        // Draw outline
                        this.ctx.save();
                        this.ctx.globalAlpha = layer.alpha;
                        this.ctx.lineWidth = layer.lineWidth / this.zoom;
                        this.ctx.strokeStyle = layer.color;
                        this.ctx.strokeRect(shape.x, shape.y, shape.width, shape.height);
                        this.ctx.restore();
                    } else if (shape.type === 'path') {
                        // Draw path (open polyline with width)
                        if (shape.points.length < 2) return;

                        // Draw main path with butt caps
                        this.ctx.save();
                        this.ctx.globalAlpha = layer.alpha;
                        this.ctx.lineWidth = shape.width || 1;
                        this.ctx.lineCap = 'butt';
                        this.ctx.lineJoin = 'miter';
                        this.ctx.strokeStyle = layer.color;

                        this.ctx.beginPath();
                        this.ctx.moveTo(shape.points[0].x, shape.points[0].y);
                        for (let i = 1; i < shape.points.length; i++) {
                            this.ctx.lineTo(shape.points[i].x, shape.points[i].y);
                        }
                        this.ctx.stroke();
                        this.ctx.restore();

                        // Draw centerline spine in black
                        this.ctx.save();
                        this.ctx.globalAlpha = layer.alpha;
                        this.ctx.lineWidth = 1 / this.zoom;
                        this.ctx.strokeStyle = 'black';
                        this.ctx.lineCap = 'butt';

                        this.ctx.beginPath();
                        this.ctx.moveTo(shape.points[0].x, shape.points[0].y);
                        for (let i = 1; i < shape.points.length; i++) {
                            this.ctx.lineTo(shape.points[i].x, shape.points[i].y);
                        }
                        this.ctx.stroke();
                        this.ctx.restore();
                    } else if (shape.type === 'polygon') {
                        // Draw polygon (closed filled shape) with pattern or solid color
                        if (shape.points.length < 3) return;

                        // Fill with pattern or solid color
                        if (!layer.outlineOnly) {
                            this.ctx.save();
                            this.ctx.globalAlpha = this.patternsEnabled ? layer.alpha : layer.alpha * this.globalOpacity;

                            if (this.patternsEnabled) {
                                // Draw with pattern
                                this.ctx.scale(1 / this.zoom, 1 / this.zoom);
                                this.ctx.fillStyle = layer.pattern;
                                this.ctx.beginPath();
                                this.ctx.moveTo(shape.points[0].x * this.zoom, shape.points[0].y * this.zoom);
                                for (let i = 1; i < shape.points.length; i++) {
                                    this.ctx.lineTo(shape.points[i].x * this.zoom, shape.points[i].y * this.zoom);
                                }
                                this.ctx.closePath();
                                this.ctx.fill();
                            } else {
                                // Draw with solid color
                                this.ctx.fillStyle = layer.color;
                                this.ctx.beginPath();
                                this.ctx.moveTo(shape.points[0].x, shape.points[0].y);
                                for (let i = 1; i < shape.points.length; i++) {
                                    this.ctx.lineTo(shape.points[i].x, shape.points[i].y);
                                }
                                this.ctx.closePath();
                                this.ctx.fill();
                            }
                            this.ctx.restore();
                        }

                        // Draw outline in layer color
                        this.ctx.save();
                        this.ctx.globalAlpha = layer.alpha;
                        this.ctx.lineWidth = layer.lineWidth / this.zoom;
                        this.ctx.strokeStyle = layer.color;
                        this.ctx.beginPath();
                        this.ctx.moveTo(shape.points[0].x, shape.points[0].y);
                        for (let i = 1; i < shape.points.length; i++) {
                            this.ctx.lineTo(shape.points[i].x, shape.points[i].y);
                        }
                        this.ctx.closePath();
                        this.ctx.stroke();
                        this.ctx.restore();
                    } else if (shape.type === 'text') {
                        // Draw text label
                        this.ctx.save();
                        this.ctx.globalAlpha = layer.alpha;
                        this.ctx.fillStyle = layer.color;
                        this.ctx.strokeStyle = 'white';

                        // Calculate font size and stroke width proportional to font size (not zoom)
                        const fontSize = shape.fontSize || this.defaultFontSize;
                        this.ctx.lineWidth = fontSize * this.textOutlineRatio;
                        this.ctx.font = `${fontSize}px Arial`;
                        this.ctx.textAlign = 'center';
                        this.ctx.textBaseline = 'middle';

                        // Draw text with white outline for better visibility
                        this.ctx.strokeText(shape.text, shape.x, shape.y);
                        this.ctx.fillText(shape.text, shape.x, shape.y);
                        this.ctx.restore();
                    }
                }); // end shapes forEach
            }); // end layers forEach

            // Restore context for this pass
            this.ctx.restore();
        } // End multi-pass loop

        // Draw rulers (on top of everything) - only once, not multi-sampled
        if (this.rulersVisible) {
            // Apply transformations for rulers
            this.ctx.translate(this.pan.x, this.pan.y);
            this.ctx.scale(this.zoom, this.zoom);
            this.drawRulers();
        }

        // Restore context
        this.ctx.restore();
    }
}

// Initialize viewer when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize with empty layout
    window.SHAPES_DATA = [];
    const viewer = new LayoutViewer('canvas');
});
