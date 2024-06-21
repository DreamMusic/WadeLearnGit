
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- local items = {
    --     "framework.display",
    --     "framework.crypto",
    --     "framework.network",
    --     "framework.luabinding",
    --     "framework.socketTcp",
    -- }

    -- self:addChild(game.createMenu(items, handler(self, self.openTest)))

    
    self:testScroll()

end

function MainScene:testScroll()
    local itemWidth,itemHeight = 120,display.height
    local colorTbl = {}
    for i = 1,8,1 do
        local colorIndex = ccc4(math.random(1,255), math.random(1,255), math.random(1,255), 255)
        table.insert(colorTbl, colorIndex)
    end
    local function createListItem(index)
        local item = display.newNode()
        local backgroundIndex = ((index - 1) % 8) + 1
        local colorIndex = colorTbl[backgroundIndex]
        local background = CCLayerColor:create(colorIndex)
        background:setContentSize(itemWidth,itemHeight)
        item:addChild(background)

        local labelNode = display.newNode()
        item:addChild(labelNode)
        for j = 1, 6,1 do
            local label = cc.ui.UILabel.new({
                UILabelType = 2,
                text = (index - 1) * 6 + j,
                size = 20
            })
            label:setPosition(background:getContentSize().width / 2, background:getContentSize().height / 2 - j * 20)
            labelNode:addChild(label)
            label:setTag(j)
        end
        item.labelNode = labelNode

        item.background = background
        item.colorIndex = colorIndex

        local labelEx = cc.ui.UILabel.new({
            UILabelType = 2,
            text = "方块" .. index,
            size = 20
        })
        background:setAnchorPoint(0.5,0.5)
        labelEx:setPosition(background:getContentSize().width / 2, background:getContentSize().height / 2 + 50)
        item:addChild(labelEx)
        item.labelEx = labelEx

    
        return item
    end


    
    local function populateScrollView(layer, itemCount)
        local innerWidth = itemCount * itemWidth
        local scrollNode = display.newNode()
        layer:addScrollNode(scrollNode) -- 确保创建一个滚动节点
        layer:getScrollNode():setContentSize(cc.size(innerWidth, itemHeight)) -- 设置滚动节点的内容大小

        local visibleItemCount = 8 -- 固定显示8个可见项
        layer.items = {}
        layer.innerWidth = innerWidth
    
        for i = 1, visibleItemCount do
            local item = createListItem(i)
            scrollNode:addChild(item)
            item:setPosition((i-1) * itemWidth, 0)
            table.insert(layer.items, item)
        end
    
        layer.itemCount = itemCount
        layer.visibleItemCount = visibleItemCount
    end

    local function updateItems(scrollView)
        local offsetX = -scrollView:getScrollNode():getPositionX()
        local visibleStartIndex = math.floor(offsetX / itemWidth) + 1
        local tbl = {}
        local tblEx = {}
        for i = 1, scrollView.visibleItemCount do
            local tempVal = visibleStartIndex + i - 1
            local backgroundIndex = ((tempVal - 1) % 8) + 1
            table.insert(tbl, backgroundIndex)
            table.insert(tblEx, tempVal)
        end


        for i = 1, #tbl, 1 do
            local item = scrollView.items[tbl[i]]
            item:setPosition((tblEx[i] - 1) * itemWidth, 0)
            local tempVal = tblEx[i]
            if tempVal >= 1 and tempVal <= scrollView.itemCount then
                for j = 1, 6,1 do
                    local label = item.labelNode:getChildByTag(j)
                    label:setString((tempVal - 1) * 6 + j)
                end
                item.labelEx:setString("方块"..tempVal)
            end
        end

        -- for i = 1, scrollView.visibleItemCount do
        --     local item = scrollView.items[i]
        --     local itemIndex = visibleStartIndex + i - 1
        --     if itemIndex >= 1 and itemIndex <= scrollView.itemCount then
        --         item:setPosition((itemIndex - 1) * itemWidth, 0)
        --         for j = 1, 6,1 do
        --             local label = item.labelNode:getChildByTag(j)
        --             label:setString((itemIndex - 1) * 6 + j)
        --         end
   
        --         local backgroundIndex = ((itemIndex - 1) % 8) + 1
        --         -- print("updateItems", itemIndex,backgroundIndex)
        --         item.labelEx:setString("方块"..backgroundIndex)
        --         item.background:setColor(ccc3(colorTbl[backgroundIndex].r,colorTbl[backgroundIndex].g,colorTbl[backgroundIndex].b))
        --     end
        -- end
    end
    
    local function onScrollViewEvent(event) 
        local scrollView = event.scrollView
        if event.name == "scroll" or event.name == "moved" then
            local offsetX = scrollView:getScrollNode():getPositionX()
            if offsetX > 0 then
                scrollView:getScrollNode():setPositionX(0)
            elseif offsetX <= -(scrollView.itemCount*120 - display.width) then
                scrollView:getScrollNode():setPositionX(-(scrollView.itemCount*120 - display.width))
            end
            updateItems(scrollView)
        elseif event.name == 'ended' then
            scrollView:getScrollNode():setTouchEnabled(true) 
        end
    end
    
    
    
    local layer = cc.ui.UIScrollView.new({
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        viewRect = cc.rect(0, 0, display.width, display.height) -- 宽度调整为800以容纳8个项
    })
    layer:setPosition(cc.p(0,0))
    self:addChild(layer)
    layer:setBounceable(false)
    layer:setTouchEnabled(true)
    layer:onScroll(onScrollViewEvent)
    local itemCount = 50 -- 假设有50个列表项 关卡数等于itemCount * 6
    populateScrollView(layer, itemCount)
    updateItems(layer) -- 初始化时更新一次可见项
end


function MainScene:onEnter()
end

return MainScene
