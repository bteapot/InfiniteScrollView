//
//  InfiniteScrollView.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 23.04.2021.
//

import Foundation
import UIKit


public final class InfiniteScrollView: UIScrollView {
    
    // MARK: - Инициализация
    
    public required init(
        frame:      CGRect,
        direction:  Direction,
        dataSource: InfiniteScrollViewDataSource?,
        taps:       Bool = true,
        reserve:    CGFloat = 0
    ) {
        // параметры
        self.direction = direction
        self.dataSource = dataSource
        self.reserve = reserve
        
        // инициализация
        super.init(frame: frame)
        
        // свойства
        self.autoresizesSubviews = false
        self.bounces = true
        self.scrollsToTop = false
        self.contentInsetAdjustmentBehavior = .always
        
        switch direction {
        case .horizontal: self.showsHorizontalScrollIndicator = false
        case .vertical:   self.showsVerticalScrollIndicator = false
        }
        
        // тап
        if taps {
            let tapGR =
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(tapped(gr:))
                )
            self.addGestureRecognizer(tapGR)
            self.tapGR = tapGR
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Источник данных
    
    public weak var dataSource: InfiniteScrollViewDataSource? {
        didSet {
            self.reset()
        }
    }
    
    public func reset() {
        // очистим список элементов
        self.items.forEach { $0.view.removeFromSuperview() }
        self.items = []
        
        // скомандуем перевёрстку
        self.setNeedsLayout()
    }
    
    // MARK: - Элементы
    
    public internal(set) var items: [Item] = []
    
    private func offset(items: [Item], by value: CGFloat) {
        items.forEach { $0.shift(by: value) }
    }
    
    public func centered() -> Item? {
        let point: CGPoint =
            self.bounds
                .inset(by: self.adjustedContentInset)
                .center
        
        return self.items
            .first(
                where: {
                    $0.view.frame
                        .expanded(by: self.adjustedContentInset)
                        .contains(point)
                }
            )
    }
    
    // MARK: - Геометрия
    
    let direction:    Direction
    let reserve:      CGFloat
    var lastInsetted: CGRect = .zero
    
    public override var bounds: CGRect {
        didSet {
            // текущее начало видимой области
            let minLon: CGFloat =
                self.direction.minLon(of: self.bounds)
            
            // есть вылеты?
            if minLon < 0 {
                // сдвинем в ноль
                self.bounds =
                    self.direction.offset(
                        rect: self.bounds,
                        lon: -minLon,
                        lat: 0
                    )
            }
        }
    }
    
    public override func layoutSubviews() {
        // поправим размер контента, до кратного странице
        self.adjustContentSize()
        
        // поправим положение элементов при изменении видимого прямоугольника
        self.recenterItems()
        
        // поправим положение видимого прямоугольника
        self.adjustLon()
        
        // расставим элементы
        self.fillItems()
        
        // сообщим об отображённом элементе
        self.report()
    }
    
    private func adjustContentSize() {
        // поправим размер контента до кратного странице
        
        // длина bounds
        let boundsLon: CGFloat =
            self.direction.lenLon(of: self.bounds)
        
        // safe-область
        let insetted: CGRect =
            self.bounds
                .inset(by: self.adjustedContentInset)
        
        // ширина safe-области
        let safeLat: CGFloat =
            self.direction.lenLat(of: insetted)
        
        // длина контента
        let contentLon: CGFloat =
            boundsLon * 5
        
        // изменилась длина bounds или ширина safe-области?
        if  contentLon != self.direction.lon(of: self.contentSize) ||
            safeLat != self.direction.lat(of: self.contentSize)
        {
            self.contentSize =
                self.direction.size(
                    lon: contentLon,
                    lat: safeLat
                )
        }
    }
    
    private func recenterItems() {
        // поправим положение элементов при изменении видимого прямоугольника
        
        // старая область
        let oldInsetted: CGRect =
            self.lastInsetted
        
        // новая safe-область
        var newInsetted: CGRect =
            self.bounds
                .inset(by: self.adjustedContentInset)
        
        // убедимся, что уже есть, что поправлять
        guard self.items.isEmpty == false else {
            return
        }
        
        // новая – валидна?
        guard newInsetted.isEmpty == false else {
            return
        }
        
        // длина safe-области изменилась?
        guard self.direction.lenLon(of: newInsetted) != self.direction.lenLon(of: oldInsetted) else {
            return
        }
        
        // центральная точка старой safe-области
        let oldCenter: CGPoint =
            oldInsetted.center
        
        // центральный для старой safe-области элемент
        let centeredIndex: Int =
            self.items.firstIndex(where: { $0.view.frame.contains(oldCenter) }) ??
            self.items.indices.count / 2
        
        let centeredItem: Item =
            self.items[centeredIndex]
        
        // коэффициент эксцентричности элемента в старой области
        let excentricRatio: CGFloat = {
            let insettedMidLon: CGFloat =
                self.direction.midLon(of: oldInsetted)
            
            let insettedLenLon: CGFloat =
                self.direction.lenLon(of: oldInsetted)
            
            let itemMidLon: CGFloat =
                centeredItem.midLon
            
            let excentricRatio: CGFloat =
                (itemMidLon - insettedMidLon) / insettedLenLon
            
            return excentricRatio.isNaN || excentricRatio.isInfinite ? 0 : excentricRatio
        }()
        
        // постраничное листание?
        if self.isPagingEnabled {
            // выровняем видимую область по границе страницы
            
            // длина bounds
            let lenLon: CGFloat =
                self.direction.lenLon(of: self.bounds)
            
            // текущее начало видимой области
            let minLon: CGFloat =
                self.direction.minLon(of: self.bounds)
            
            // подвинем bounds в значение, кратное видимой области
            self.bounds =
                self.direction.offset(
                    rect: self.bounds,
                    lon:  (minLon / lenLon).rounded(.toNearestOrAwayFromZero) * lenLon,
                    lat:  0
                )
            
            // обновим новую safe-область
            newInsetted =
                self.bounds
                    .inset(by: self.adjustedContentInset)
        }
        
        // поставим центральный элемент
        centeredItem.center(
            ratio:    excentricRatio,
            insetted: newInsetted
        )
        
        // расстояние между элементами
        let interitem: CGFloat =
            self.isPagingEnabled ?
                self.direction.lon(of: self.adjustedContentInset) :
                0
        
        // поправим элементы перед центральным
        Array(0..<centeredIndex)
            .reversed()
            .forEach { index in
                self.items[index].place(
                    position:  .before,
                    point:     self.items[index + 1].minLon,
                    insetted:  newInsetted,
                    interitem: interitem
                )
            }
        
        // поправим элементы после центрального
        Array(centeredIndex+1..<self.items.endIndex)
            .forEach { index in
                self.items[index].place(
                    position:  .after,
                    point:     self.items[index - 1].maxLon,
                    insetted:  newInsetted,
                    interitem: interitem
                )
            }
    }
    
    private func adjustLon() {
        // сдвинем контент, если слишком близко к одному из двух краёв
        
        // длина видимой области
        let boundsLon: CGFloat =
            self.direction.lenLon(of: self.bounds)
        
        // длина контента
        let contentLon: CGFloat =
            self.direction.lon(of: self.contentSize)
        
        // мало в начале?
        let minLon: CGFloat =
            self.direction.minLon(of: self.bounds)
        
        if minLon - boundsLon <= 0 {
            // двигаем видимую область
            self.bounds =
                self.direction.offset(
                    rect: self.bounds,
                    lon:  boundsLon,
                    lat:  0
                )
            
            // двигаем элементы
            self.offset(items: self.items, by: boundsLon)
        }
        
        // мало в конце?
        let maxLon: CGFloat =
            self.direction.maxLon(of: self.bounds)
        
        if maxLon + boundsLon >= contentLon {
            // двигаем видимую область
            self.bounds =
                self.direction.offset(
                    rect: self.bounds,
                    lon:  -boundsLon,
                    lat:  0
                )
            
            // двигаем элементы
            self.offset(items: self.items, by: -boundsLon)
        }
        
        // запомним текущую safe-область
        self.lastInsetted =
            self.bounds
                .inset(by: self.adjustedContentInset)
    }
    
    private func fillItems() {
        // расставим элементы
        
        // убедимся, что есть источник данных
        guard let dataSource = self.dataSource else {
            return
        }
        
        // метрики safe-области
        let bounds: CGRect =
            self.bounds
        
        let insetted: CGRect =
            bounds.inset(by: self.adjustedContentInset)
        
        // расстояние между элементами
        let interitem: CGFloat =
            self.isPagingEnabled ?
                self.direction.lon(of: self.adjustedContentInset) :
                0
        
        // ещё нет элементов?
        if self.items.isEmpty {
            // получим первый
            let item =
                Item(
                    scrollView: self,
                    dataSource: dataSource,
                    index: dataSource.initialIndex(isv: self)
                )
            
            // поставим прям посреди видимой области
            item.place(
                position:  .center,
                point:     self.direction.midLon(of: insetted),
                insetted:  insetted,
                interitem: 0
            )
            
            self.addSubview(item.view)
            
            // сохраним
            self.items = [item]
            
            // не сообщаем о нём
            self.reportedIndex = item.index
        }
        
        // резерв длины для вьюх с фоновой отрисовкой
        let reserve: CGFloat =
            self.reserve
        
        // добавление и убирание элементов – без анимации
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // не хватает в начале?
        let minLon: CGFloat =
            self.direction.minLon(of: bounds)
        
        while
            let first = self.items.first,
            first.minLon > minLon - reserve
        {
            // получим ещё один
            let item =
                Item(
                    scrollView: self,
                    dataSource: dataSource,
                    index: first.index - 1
                )
            
            // поставим перед первым
            item.place(
                position:  .before,
                point:     first.minLon,
                insetted:  insetted,
                interitem: interitem
            )
            
            self.addSubview(item.view)
            
            // добавим в начало списка
            self.items.insert(item, at: 0)
        }
        
        // не хватает в конце?
        let maxLon: CGFloat =
            self.direction.maxLon(of: bounds)
        
        while
            let last = self.items.last,
            last.maxLon < maxLon + reserve
        {
            // получим ещё один
            let item =
                Item(
                    scrollView: self,
                    dataSource: dataSource,
                    index: last.index + 1
                )
            
            // поставим после последнего
            item.place(
                position:  .after,
                point:     last.maxLon,
                insetted:  insetted,
                interitem: interitem
            )
            
            self.addSubview(item.view)
            
            // добавим в начало списка
            self.items.append(item)
        }
        
        // подчистим уехавшие, если не в состоянии прокрутки
        if self.scrolling == 0 {
            let expanded: CGRect =
                bounds.expanded(by: self.direction.insets(startLon: reserve, endLon: reserve))
            
            self.items =
                self.items.compactMap { item in
                    if item.view.frame.intersects(expanded) {
                        // вьюха видна, оставляем
                        return item
                    } else {
                        // вьюха уехала, убираем
                        item.view.removeFromSuperview()
                        return nil
                    }
                }
        }
        
        // всё, новые добавлены, старые убраны
        CATransaction.commit()
    }
    
    // MARK: - Отчёт
    
    private var reportedIndex: Int = 0
    
    private func report() {
        // убедимся, что есть источник данных
        guard let dataSource = self.dataSource else {
            return
        }
        
        // сообщим об отцентрованном элементе?
        if  self.scrolling == 0,
            let item = self.centered(),
            item.index != self.reportedIndex
        {
            // сообщим
            dataSource.shown(isv: self, view: item.view, index: item.index)
            
            // запомним, что сообщали
            self.reportedIndex = item.index
        }
    }
    
    // MARK: - Прокрутка
    
    private var scrolling: Int = 0
    
    public func scroll(to index: Int, animated: Bool) {
        // убедимся, что есть источник данных
        guard let dataSource = self.dataSource else {
            return
        }
        
        // убедимся, что элементы уже есть
        guard self.items.isEmpty == false else {
            return
        }
        
        // метрики
        let boundsLon: CGFloat =
            self.direction.lenLon(of: self.bounds)
        
        let insetted: CGRect =
            self.bounds
                .inset(by: self.adjustedContentInset)
        
        // расстояние между элементами
        let interitem: CGFloat =
            self.isPagingEnabled ?
                self.direction.lon(of: self.adjustedContentInset) :
                0
        
        // целевой элемент
        let target: Item =
            self.items.first(where: { $0.index == index }) ?? {
                // элемента с таким индексом нет, сделаем
                let target =
                    Item(
                        scrollView: self,
                        dataSource: dataSource,
                        index: index
                    )
                
                // вычислим длину элемента
                target.place(
                    position:  .after,
                    point:     0,
                    insetted:  insetted,
                    interitem: 0
                )
                
                // соберём массив добавляемых вьюх так, чтобы после прокрутки к целевому все текущие ушли из виду
                var items: [Item] =
                    [target]
                
                // направление заполнения
                let descending: Bool =
                    self.items[0].index > index
                
                // резерв длины для вьюх с фоновой отрисовкой
                let reserve: CGFloat =
                    self.reserve
                
                // заполняемая длина
                var gap: CGFloat =
                    (boundsLon - target.lenLon) / 2 + reserve
                
                // фактическая длина новых элементов
                var actual: CGFloat =
                    target.lenLon + interitem
                
                // прошлый элемент
                var previous: Item =
                    target
                
                // набьём массив до заполнения видимой области, или до достижения непрерывности индексов элементов
                while
                    gap > 0,
                    self.items.contains(where: { $0.index == previous.index + (descending ? 1 : -1) }) == false
                {
                    // получим элемент
                    let item =
                        Item(
                            scrollView: self,
                            dataSource: dataSource,
                            index: previous.index + (descending ? 1 : -1)
                        )
                    
                    // вычислим длину элемента
                    item.place(
                        position:  descending ? .after : .before,
                        point:     descending ? previous.maxLon : previous.minLon,
                        insetted:  insetted,
                        interitem: interitem
                    )
                    
                    // вычтем длину элемента из заполняемой
                    gap -= item.lenLon + interitem
                    
                    // добавим длину элемента к общей
                    actual += item.lenLon + interitem
                    
                    // положим в массив
                    items.insert(item, at: descending ? items.count : 0)
                    
                    // для следующего цикла
                    previous = item
                }
                
                // подвинем массив ровно под уже имеющиеся
                self.offset(
                    items: items,
                    by: descending ?
                        self.items[0].minLon - actual :
                        self.items[self.items.count - 1].maxLon + actual - target.lenLon
                )
                
                // добавим новые
                self.items =
                    descending ?
                        items + self.items :
                        self.items + items
                
                items.forEach { self.addSubview($0.view) }
                
                // вернём целевую
                return target
            }()
        
        // текущее начало bounds
        let boundsMinLon: CGFloat =
            self.direction.minLon(of: self.bounds)
        
        // отступ в начале
        let insetsStartLon: CGFloat =
            self.direction.startLon(of: self.adjustedContentInset)
        
        // ширина safe-области
        let insettedLon: CGFloat =
            self.direction.lenLon(of: insetted)
        
        // прямоугольник, к которому будем крутить
        let bounds: CGRect =
            self.direction.offset(
                rect: self.bounds,
                lon:  target.minLon - boundsMinLon - insetsStartLon - (insettedLon - target.lenLon) / 2,
                lat:  0
            )
        
        // останавливаем текущую анимацию
        self.setContentOffset(self.contentOffset, animated: false)
        
        // отмечаем, что при вёрстке элементы убирать не надо
        self.scrolling += 1
        
        // не сообщаем о целевой вьюхе
        self.reportedIndex = target.index
        
        // крутим
        UIView.animate(
            withDuration: animated ? 0.25 : 0,
            delay: 0,
            options: [],
            animations: {
                self.bounds = bounds
                self.adjustLon()
            },
            completion: { finished in
                // разрешим прибраться
                self.scrolling -= 1
                self.setNeedsLayout()
            }
        )
    }
    
    // MARK: - Тап
    
    public private(set) var tapGR: UITapGestureRecognizer?
    
    @objc
    private func tapped(gr: UITapGestureRecognizer) {
        // убедимся, что есть источник данных
        guard let dataSource = self.dataSource else {
            return
        }
        
        // поищем вьюху, в которой было касание
        for item in self.items {
            // точка касания внутри вьюхи
            let point = gr.location(in: item.view)
            
            if item.view.bounds.contains(point) {
                dataSource.tap(isv: self, view: item.view, index: item.index, point: point)
                return
            }
        }
    }
}
